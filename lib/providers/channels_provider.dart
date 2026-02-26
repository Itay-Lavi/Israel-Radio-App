import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/channel.dart';
import '../services/channels_api.dart';

class ChannelsProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playingSub;
  StreamSubscription<PlaybackEvent>? _errorSub;
  final StreamController<(Object, StackTrace)> _errorController =
      StreamController.broadcast();

  /// Emits whenever a playback error occurs that the UI should surface.
  Stream<(Object, StackTrace)> get errorStream => _errorController.stream;

  late Channel loadedChannel;
  bool _channelIsInit = false;
  bool _playerLoading = false;
  bool play = false;

  List<Channel> _channels = [];

  List<Channel> get channels => _channels.toList();

  List<Channel> get favoriteItems =>
      _channels.where((chanItem) => chanItem.isFavorite).toList();

  bool get playerLoading => _playerLoading;

  Channel findById(int id) => _channels.firstWhere((chan) => chan.id == id);

  Future<void> initData() async {
    try {
      await fetchChannels();
    } catch (e) {
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
      loadedChannel = _channels[0]; //set channel to first channel;
    }

    isPlayingTimer();
    notifyListeners();
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

    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> setChannel(Channel data, [bool autoPlay = false]) async {
    if (loadedChannel == data && _channelIsInit) {
      return;
    }
    loadedChannel = data;
    _channelIsInit = true;

    // Show loading + update channel in UI immediately
    _playerLoading = true;
    notifyListeners();

    try {
      final audioSource = AudioSource.uri(
        Uri.parse(data.radioUrl),
        tag: MediaItem(
          id: data.id.toString(),
          title: data.title,
          artUri: Uri.parse(data.imageUrl),
        ),
      );

      // setAudioSource is fire-and-forget — live streams block indefinitely if awaited.
      // Attach catchError so a startup network failure is caught and surfaced to the UI.
      _player.setAudioSource(audioSource).catchError((Object e, StackTrace st) {
        _handlePlayerError(e, st, notify: true);
        return null;
      });

      if (autoPlay || play) {
        _player.play();
      }
    } catch (e) {
      _player.stop();
      _playerLoading = false;
      _setPlayState(false);
      return Future.error(e);
    } finally {
      loadedChannel.saveLoadedChannel();
    }
  }

  Future<void> moveChannels(int direction) async {
    // +1 = forward , -1 = backward
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

  /// Resets player state and, when [notify] is true, pushes the error onto
  /// [errorStream] so the active widget can show a toast.
  void _handlePlayerError(Object error, StackTrace stackTrace,
      {bool notify = false}) {
    debugPrint('[ChannelsProvider] Playback error: $error');
    debugPrint(stackTrace.toString());
    _playerLoading = false;
    play = false;
    notifyListeners();
    if (notify && !_errorController.isClosed) {
      _errorController.add((error, stackTrace));
    }
  }

  void isPlayingTimer() {
    _playingSub?.cancel();
    _errorSub?.cancel();

    // Catch stream-level errors (e.g. no internet, stream drop)
    _errorSub = _player.playbackEventStream.listen(
      null,
      onError: _handlePlayerError,
    );

    // Drive both play and loading state from the player's real-time state
    _playingSub = _player.playerStateStream.listen((state) {
      final isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
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
    _playingSub?.cancel();
    _errorSub?.cancel();
    _errorController.close();
    _player.dispose();
    super.dispose();
  }
}
