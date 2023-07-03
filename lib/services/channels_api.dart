import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../models/channel.dart';

class ChannelsApi {
  static const String _imagesBaseUrl =
      "https://firebasestorage.googleapis.com/v0/b/"
      "israelradio-87ac7"
      ".appspot.com/o/radioImages%2F";

  static Future<List<Channel>> fetchChannels() async {
    final url = Uri.https('pastebin.com', '/raw/dz7qLi5B');
    late Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      throw Exception('SocketException');
    }

    if (response.statusCode != 200) throw Exception('SocketException');

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final sortedData = SplayTreeMap.from(
      extractedData,
      (a, b) => extractedData[a]['id'].compareTo(extractedData[b]['id']),
    );

    final channelsFetch = <Channel>[];

    sortedData.forEach((prodId, prodData) {
      try {
        final imageUrl = "${_imagesBaseUrl + prodData['imageUrl']}?alt=media";
        channelsFetch.add(
          Channel(
            id: prodData['id'],
            title: prodData['title'],
            radioUrl: prodData['radioUrl'],
            imageUrl: imageUrl,
          ),
        );
      } catch (_) {}
    });

    return channelsFetch;
  }
}
