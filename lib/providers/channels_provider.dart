import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/channel.dart';

class ChannelsProvider with ChangeNotifier {
  final String _imagesBaseUrl = "https://firebasestorage.googleapis.com/v0/b/"
      "israelradio-87ac7"
      ".appspot.com/o/radioImages%2F";

  final AssetsAudioPlayer _radioPlayer = AssetsAudioPlayer.withId('1');
  late Channel loadedChannel;
  bool _channelIsInit = false;
  bool _playerLoading = false;
  bool play = false;

  List<Channel> _channels = [];

  List<Channel> get channels {
    return [..._channels]; //.toList()
  }

  List<Channel> get favoriteItems {
    return [..._channels.where((chanItem) => chanItem.isFavorite)];
  }

  Channel findById(int id) {
    return _channels.firstWhere((chan) => chan.id == id);
  }

  void updatePlayerLoading(bool loading) {
    _playerLoading = loading;
    notifyListeners();
  }

  bool get playerLoading {
    return _playerLoading;
  }

  Future<void> playOrPause() async {
    try {
      updatePlayerLoading(true);
      if (!_channelIsInit) {
        await setChannel(loadedChannel);
        _channelIsInit = true;
      }
      await _radioPlayer.playOrPause();
    } catch (e) {
      updatePlayerLoading(false);
      rethrow;
    }
    updatePlayerLoading(false);
  }

  Future<void> setChannel(Channel data, [bool autoPlay = false]) async {
    if (loadedChannel == data && _channelIsInit) {
      return;
    }
    loadedChannel = data;

    try {
      await _radioPlayer.open(
          Audio.liveStream(
            data.radioUrl,
            metas: Metas(
                title: data.title, image: MetasImage.network(data.imageUrl)),
          ),
          autoStart: autoPlay ? true : play,
          playInBackground: PlayInBackground.enabled,
          showNotification: true,
          notificationSettings: const NotificationSettings(
              playPauseEnabled: true,
              stopEnabled: true,
              nextEnabled: false,
              prevEnabled: false,
              seekBarEnabled: false));
      //שומר את המידע
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('channel', loadedChannel.id);
    } catch (err) {
      rethrow;
    }

    _channelIsInit = true;
    notifyListeners();
  }

  Future<void> moveChannels(int direction) async {
    // +1 = forward , -1 = backward
    Channel loaded;

    final int nextChannel = _channels.indexOf(loadedChannel) + direction;
    if (nextChannel > _channels.length - 1) {
      loaded = findById(0);
    } else if (nextChannel < 0) {
      loaded = findById(_channels.length - 1);
    } else {
      loaded = findById(nextChannel);
    }

    try {
      updatePlayerLoading(true);
      await setChannel(loaded);
      updatePlayerLoading(false);
    } catch (e) {
      updatePlayerLoading(false);
      rethrow;
    }
  }

  Future<void> initData() async {
    try {
      await fetchChannels();
    } catch (error) {
      return Future.error(error);
    }

    final prefs = await SharedPreferences.getInstance();
    for (var channel in _channels) {
      if (prefs.getBool('favorite${channel.id}') == true) {
        channel.isFavorite = prefs.getBool('favorite${channel.id}')!;
      }
    }

    final int? data = prefs.getInt('channel');
    if (data != null) {
      loadedChannel = findById(data);
    } else {
      loadedChannel = _channels[0];
    }
    isPlayingTimer();
    notifyListeners();
  }

  Future<void> fetchChannels() async {
    Uri url = Uri.https('pastebin.com', '/raw/dz7qLi5B');

    final response = await http.get(url);

    //If the http request is successful the statusCode will be 200
    if (response.statusCode == 200) {
      final extractedData =
          json.decode(response.body) as Map<String, dynamic>; //decode to map

      final sortedData = SplayTreeMap.from(
          extractedData,
          (a, b) => extractedData[a]['id']
              .compareTo(extractedData[b]['id'])); //Sorting data by id

      final List<Channel> channelsFetch =
          []; //create a copy if function get exception

      sortedData.forEach((prodId, prodData) {
        //add fetched radio list
        try {
          final imageUrl = "${_imagesBaseUrl + prodData['imageUrl']}?alt=media";

          channelsFetch.add(Channel(
              id: prodData['id'],
              title: prodData['title'],
              radioUrl: prodData['radioUrl'],
              imageUrl: imageUrl));
          // ignore: empty_catches
        } catch (e) {}
      });
      _channels = channelsFetch;
    } else {
      return Future.error('SocketException');
    }
  }

  void isPlayingTimer() {
    _radioPlayer.isPlaying.listen((isPlaying) {
      if (play != isPlaying) {
        play = isPlaying;
        notifyListeners();
      }
    });
  }
}
