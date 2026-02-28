import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';

import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';

import '../models/channel.dart';
import '../services/audio_player_handler.dart';
import '../services/channels_api.dart';

class ChannelsProvider with ChangeNotifier {
  late final RadioAudioHandler _handler;
  Future<void> Function()? _syncAlarmsCallback;
  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<(Object, StackTrace)>? _errorSub;

  final StreamController<(Object, StackTrace)> _errorController =
      StreamController.broadcast();

  Stream<(Object, StackTrace)> get errorStream => _errorController.stream;

  late Channel loadedChannel;
  bool _channelIsInit = false;
  bool _playerLoading = false;
  bool play = false;
  bool _isInitialized = false;
  bool _alarmHandled = false;

  List<Channel> _channels = [];

  List<Channel> get channels => _channels.toList();

  List<Channel> get favoriteItems =>
      _channels.where((chanItem) => chanItem.isFavorite).toList();

  bool get playerLoading => _playerLoading;

  Channel findById(int id) => _channels.firstWhere((chan) => chan.id == id);

  void setSyncAlarmsCallback(Future<void> Function() fn) {
    _syncAlarmsCallback = fn;
  }

  void setHandler(RadioAudioHandler handler) {
    _handler = handler;

    _errorSub?.cancel();
    _errorSub = _handler.errorController.stream.listen((record) {
      if (!_errorController.isClosed) {
        _errorController.add(record);
      }
      // Error while playing — treat as paused so the UI reflects reality.
      _playerLoading = false;
      _setPlayState(false);
    });

    // Re-register the foreground alarm handler.
    FlutterAlarmBackgroundTrigger().onForegroundAlarmEventHandler((alarms) {
      final fired = alarms.where((a) => a.status == AlarmStatus.DONE).toList();
      if (fired.isNotEmpty && !_alarmHandled) _onAlarmItemFired(fired.first);
    });
  }

  Future<void> initData() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      await fetchChannels();
    } catch (e) {
      _isInitialized = false;
      return Future.error(e);
    }

    final prefs = await SharedPreferences.getInstance();
    for (Channel channel in _channels) {
      final favoriteKey = 'favorite${channel.id}';
      if (prefs.getBool(favoriteKey) == true) {
        channel.isFavorite = prefs.getBool(favoriteKey)!;
      }
    }

    final int? data = prefs.getInt('channel');
    if (data != null) {
      loadedChannel = findById(data);
    } else {
      loadedChannel = _channels[0];
    }

    try {
      // Cold-start fallback: if the foreground handler missed the event while
      // the engine was attaching, poll getAllAlarms() for any unhandled DONE alarm.
      final plugin = FlutterAlarmBackgroundTrigger();
      final allAlarms = await plugin.getAllAlarms();
      final handledTime = prefs.getString('_handledAlarmTime');
      final firedAlarms = allAlarms
          .where((a) =>
              a.status == AlarmStatus.DONE &&
              (handledTime == null || a.time?.toIso8601String() != handledTime))
          .toList();

      if (firedAlarms.isNotEmpty && !_alarmHandled) {
        _listenToPlaybackState();
        await _onAlarmItemFired(firedAlarms.first);
        return;
      }
    } catch (_) {}

    _listenToPlaybackState();
    notifyListeners();
  }

  Future<void> _doSync() async {
    try {
      if (_syncAlarmsCallback != null) {
        await _syncAlarmsCallback!();
      }
    } catch (_) {}
  }

  Future<void> _onAlarmItemFired(AlarmItem alarm) async {
    final now = DateTime.now();
    // Allow up to 2 minutes: real-device cold starts in release mode can easily
    // take over a minute between alarm fire time and initData completing.
    if (alarm.time != null && now.difference(alarm.time!).inMinutes.abs() > 2) {
      return;
    }

    _alarmHandled = true;
    if (alarm.time != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            '_handledAlarmTime', alarm.time!.toIso8601String());
      } catch (_) {}
    }
    // Give AudioService / audio_service a few seconds to fully attach after a
    // cold start before we try to set volume or start playback.
    await Future.delayed(const Duration(seconds: 3));
    try {
      final prefs = await SharedPreferences.getInstance();
      final volume = (prefs.getDouble('scheduleVol') ?? 0.5).clamp(0.0, 1.0);
      VolumeController.instance.setVolume(volume);
    } catch (_) {}
    try {
      // Radio is already playing — nothing to do.
      if (_channelIsInit && play) return;
      await _doSync();
      _channelIsInit = false;
      _listenToPlaybackState();
      notifyListeners();
      await setChannel(loadedChannel, true);
      _moveToBackgroundAfterPlay();
    } catch (e) {
      _errorController.add((e, StackTrace.current));
    } finally {
      // Always reset so future alarms in the same process are not blocked.
      // Per-session dedup is handled by _handledAlarmTime in SharedPreferences.
      _alarmHandled = false;
    }
  }

  /// Waits for the player to start playing (or 5 s timeout), then moves the
  /// app to the background so the alarm doesn't leave the screen open.
  void _moveToBackgroundAfterPlay() {
    Future(() async {
      try {
        await _handler.player.playingStream
            .firstWhere((playing) => playing)
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
      try {
        await FlutterAlarmBackgroundTrigger().moveToBackground();
      } catch (_) {}
    });
  }

  Future<void> fetchChannels() async {
    final fetchedChannels = await ChannelsApi.fetchChannels();
    _channels = fetchedChannels;
  }

  void updatePlayerLoading(bool loading) {
    _playerLoading = loading;
    notifyListeners();
  }

  void _setPlayState(bool isPlaying) {
    if (play != isPlaying) {
      play = isPlaying;
      notifyListeners();
    }
  }

  Future<void> playOrPause([bool isSchedule = false]) async {
    if (isSchedule && play) return;

    if (!_channelIsInit) {
      await setChannel(loadedChannel, true);
      return;
    }

    if (_handler.player.playing) {
      _handler.pause();
    } else {
      _handler.play();
    }
  }

  Future<void> setChannel(Channel data, [bool autoPlay = false]) async {
    if (loadedChannel == data && _channelIsInit) {
      return;
    }
    loadedChannel = data;
    _channelIsInit = true;

    _playerLoading = true;
    notifyListeners();

    try {
      await _handler.customAction('setChannel', {
        'id': data.id.toString(),
        'title': data.title,
        'url': data.radioUrl,
        'imageUrl': data.imageUrl,
        'autoPlay': (autoPlay || play) ? 'true' : 'false',
      });
    } catch (e) {
      _handler.stop();
      _playerLoading = false;
      _setPlayState(false);
      return Future.error(e);
    } finally {
      loadedChannel.saveLoadedChannel();
    }
  }

  Future<void> moveChannels(int direction) async {
    if (_playerLoading) return;
    Channel loaded;

    final int nextChannel = _channels.indexOf(loadedChannel) + direction;
    if (nextChannel > _channels.length - 1) {
      loaded = findById(0);
    } else if (nextChannel < 0) {
      loaded = findById(_channels.length - 1);
    } else {
      loaded = findById(nextChannel);
    }

    await setChannel(loaded, true);
  }

  void _listenToPlaybackState() {
    _playbackSub?.cancel();

    _playbackSub = _handler.playbackState.listen((state) {
      final isLoading = state.processingState == AudioProcessingState.loading ||
          state.processingState == AudioProcessingState.buffering;
      final isPlaying = state.playing;
      if (_playerLoading != isLoading || play != isPlaying) {
        _playerLoading = isLoading;
        play = isPlaying;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _playbackSub?.cancel();
    _errorSub?.cancel();
    _errorController.close();
    super.dispose();
  }
}
