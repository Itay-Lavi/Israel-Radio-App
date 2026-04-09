import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/channel.dart';

class ChannelsApi {
  static Future<List<Channel>> fetchChannels() async {
    final url = Uri.parse(dotenv.env['RADIO_CHANNELS_URL']!);
    late List<dynamic> extractedData;

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        extractedData = json.decode(response.body) as List<dynamic>;
      } else {
        extractedData = await _loadFallback();
      }
    } catch (_) {
      extractedData = await _loadFallback();
    }

    final sorted = extractedData
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

    return sorted.map((prodData) {
      return Channel(
        id: prodData['id'] as int,
        title: prodData['title'] as String,
        radioUrl: prodData['radioUrl'] as String,
        imageUrl: prodData['imageUrl'] as String,
      );
    }).toList();
  }

  static Future<List<dynamic>> _loadFallback() async {
    final jsonString =
        await rootBundle.loadString('assets/fallback_channels.json');
    return json.decode(jsonString) as List<dynamic>;
  }
}
