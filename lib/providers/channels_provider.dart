import 'dart:async';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/channel.dart';
import '../services/channels_api.dart';

class ChannelsProvider with ChangeNotifier {
  // final _radioPlayer = AssetsAudioPlayer.withId('1');
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

  Future<void> playOrPause([bool isSchedule = false]) async {
    if (isSchedule && play) return;

    updatePlayerLoading(true);
    if (!_channelIsInit) {
      await setChannel(loadedChannel);
    }
    try {
      // await _radioPlayer
      //     .playOrPause()
      //     .timeout(Duration(seconds: isSchedule ? 60 : 12));
    } catch (e) {
      // await _radioPlayer.stop();
      return Future.error(e);
    } finally {
      updatePlayerLoading(false);
    }
  }

  Future<void> setChannel(Channel data, [bool autoPlay = false]) async {
    if (loadedChannel == data && _channelIsInit) {
      return;
    }
    loadedChannel = data;

    try {
      // await _radioPlayer
      //     .open(
      //         Audio.liveStream(
      //           data.radioUrl,
      //           metas: Metas(
      //               title: data.title,
      //               image: MetasImage.network(data.imageUrl)),
      //         ),
      //         autoStart: false,
      //         playInBackground: PlayInBackground.enabled,
      //         showNotification: true,
      //         notificationSettings: const NotificationSettings(
      //             playPauseEnabled: true,
      //             stopEnabled: true,
      //             nextEnabled: false,
      //             prevEnabled: false,
      //             seekBarEnabled: false))
      //     .timeout(const Duration(seconds: 8));
      if (autoPlay || play) {
        // await _radioPlayer.play().timeout(const Duration(seconds: 8));
      }
    } catch (e) {
      // await _radioPlayer.stop();
      return Future.error(e);
    } finally {
      _channelIsInit = true;
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

    updatePlayerLoading(true);
    await setChannel(loaded, true);
    updatePlayerLoading(false);
  }

  void isPlayingTimer() {
    // _radioPlayer.isPlaying.listen((isPlaying) {
    //   if (play != isPlaying) {
    //     play = isPlaying;
    //     notifyListeners();
    //   }
    // });
  }
}
