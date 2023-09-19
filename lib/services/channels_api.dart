import 'dart:collection';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../models/channel.dart';

class ChannelsApi {
  static Future<List<Channel>> fetchChannels() async {
    final url = Uri.parse(dotenv.env['RADIO_CHANNELS_URL']!);
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
        final imageUrl =
            "${dotenv.env['RADIO_IMAGES_URL']! + prodData['imageUrl']}?alt=media";
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
