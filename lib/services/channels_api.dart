import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle; // ← new
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/channel.dart';

class ChannelsApi {
  static Future<List<Channel>> fetchChannels() async {
    final url = Uri.parse(dotenv.env['RADIO_CHANNELS_URL']!);
    late Map<String, dynamic> extractedData;

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // fallback on non‑200
        extractedData = json.decode(response.body) as Map<String, dynamic>;
      } else {
        extractedData = await _loadFallback();
      }
    } catch (e) {
      // 2) fallback on socket/timeout/etc.
      extractedData = await _loadFallback();
    }

    // rest unchanged
    final sortedData = SplayTreeMap.from(
      extractedData,
      (a, b) => extractedData[a]['id'].compareTo(extractedData[b]['id']),
    );

    return sortedData.entries.map((entry) {
      final prodData = entry.value as Map<String, dynamic>;
      final imageUrl =
          "${dotenv.env['RADIO_IMAGES_URL']! + prodData['imageUrl']}?alt=media";
      return Channel(
        id: prodData['id'],
        title: prodData['title'],
        radioUrl: prodData['radioUrl'],
        imageUrl: imageUrl,
      );
    }).toList();
  }

  static Future<Map<String, dynamic>> _loadFallback() async {
    final jsonString =
        await rootBundle.loadString('assets/fallback_channels.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }
}
