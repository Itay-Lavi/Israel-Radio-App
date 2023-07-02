import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayItem with ChangeNotifier {
  final int id;
  final String frontedDay;
  final String backendDay;
  bool checked;

  DayItem(this.id, this.frontedDay, this.backendDay, this.checked);

  Future<void> daycheckbox(int id) async {
    checked = !checked;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scheduleDays$id', checked);
  }
}
