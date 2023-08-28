import 'package:flutter/cupertino.dart';
import 'package:radio_timer_app/services/preference_service.dart';

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
    await PreferencesService.setBoolPreference('favorite$id', isFavorite);
    notifyListeners();
  }

  Future<void> saveLoadedChannel() async {
    await PreferencesService.setIntPreference('channel', id);
  }
}
