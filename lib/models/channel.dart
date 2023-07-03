import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Channel with ChangeNotifier {
  final int id;
  final String title;
  final String radioUrl;
  final String imageUrl;
  bool isFavorite;

  Channel(
      {required this.id,
      required this.title,
      required this.radioUrl,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus() async {
    isFavorite = !isFavorite;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite$id', isFavorite);
    // print('favorite$id $isFavorite');
    notifyListeners();
  }

  Future<void> saveLoadedChannel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('channel', id);
  }
}
