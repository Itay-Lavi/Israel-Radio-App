import 'dart:async';

import 'package:flutter/material.dart';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/preference_service.dart';
import './channels_provider.dart';
import '../models/day.dart';

List<String> preferenceKeys = ['scheduleSwitch', 'scheduleTime', 'scheduleVol'];

class DaysSchedule with ChangeNotifier {
  bool _scheduleSwitch = false;
  double _scheduleVol = 0.5;
  TimeOfDay _selectedTime =
      TimeOfDay(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute - 1);

  bool get scheduleSwitch => _scheduleSwitch;
  double get scheduleVol => _scheduleVol;
  TimeOfDay get selectedTime => _selectedTime;

  final _alarmPlugin = FlutterAlarmBackgroundTrigger();

  /// Reference to [ChannelsProvider] so we can read the loaded channel.
  ChannelsProvider? _channelsProv;

  final List<DayItem> _days = [
    const DayItem(7, 'א', 'Sunday', true),
    const DayItem(1, 'ב', 'Monday', true),
    const DayItem(2, 'ג', 'Tuesday', true),
    const DayItem(3, 'ד', 'Wednesday', true),
    const DayItem(4, 'ה', 'Thursday', true),
    const DayItem(5, 'ו', 'Friday', true),
    const DayItem(6, 'ש', 'Saturday', true)
  ];

  List<DayItem> get days => [..._days];

  Future<void> initData(ChannelsProvider channelsProv) async {
    _channelsProv = channelsProv;
    await initDataFromPreferences();
    notifyListeners();
  }

  /// Convenience to get the loaded channel's alarm-relevant data.
  Map<String, String> get _channelAlarmData {
    try {
      final ch = _channelsProv?.loadedChannel;
      return {
        'channelUrl': ch?.radioUrl ?? '',
        'channelTitle': ch?.title ?? '',
        'channelImageUrl': ch?.imageUrl ?? '',
        'channelId': (ch?.id ?? 0).toString(),
      };
    } catch (_) {
      return {
        'channelUrl': '',
        'channelTitle': '',
        'channelImageUrl': '',
        'channelId': '0'
      };
    }
  }

  Future<void> syncAlarms() async {
    await _alarmPlugin.deleteAllAlarms();
    if (!_scheduleSwitch) return;

    final data = _channelAlarmData;
    final selectedDays = _days.where((d) => d.selected).toList();
    final weekdays = _getSelectedWeekdays(_days, selectedTime);

    for (int i = 0; i < weekdays.length; i++) {
      final alarmId = selectedDays[i].id * 100;
      await _alarmPlugin.addAlarm(
        weekdays[i],
        uid: alarmId.toString(),
        payload: {
          'channelId': data['channelId']!,
          'channelUrl': data['channelUrl']!,
          'channelTitle': data['channelTitle']!,
          'channelImageUrl': data['channelImageUrl']!,
          'volume': _scheduleVol,
        },
        screenWakeDuration: const Duration(minutes: 1),
      );
    }
  }

  /// Computes the next DateTime for each selected weekday at [selectedTime].
  static List<DateTime> _getSelectedWeekdays(
      List<DayItem> days, TimeOfDay selectedTime) {
    final List<DateTime> result = [];
    for (final day in days) {
      if (!day.selected) continue;
      final now = DateTime.now();
      final todayAtTime = DateTime(
          now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
      int daysToAdd = day.id - now.weekday;
      if (daysToAdd < 0 || (daysToAdd == 0 && !now.isBefore(todayAtTime))) {
        daysToAdd += 7;
      }
      final target = now.add(Duration(days: daysToAdd));
      result.add(DateTime(target.year, target.month, target.day,
          selectedTime.hour, selectedTime.minute));
    }
    return result;
  }

  Future<void> toggleMainSwitch(bool mainSwitch) async {
    final bool permisssion = await backgroundPermissions(mainSwitch);
    if (!permisssion) {
      // Snap switch back to OFF in the UI so it doesn't appear stuck ON.
      notifyListeners();
      Fluttertoast.showToast(
        msg: 'אשר הרשאות ונסה שוב',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    _scheduleSwitch = mainSwitch;
    notifyListeners();
    await PreferencesService.setBoolPreference(
        preferenceKeys[0], scheduleSwitch);

    try {
      await syncAlarms();
    } catch (e) {
      debugPrint('Error syncing alarms: $e');
    }
  }

  Future<void> toggleSelectedDay(int id) async {
    final index = _days.indexWhere((e) => e.id == id);
    _days[index] = DayItem(
        id, _days[index].hebName, _days[index].engName, !_days[index].selected);
    notifyListeners();
    await PreferencesService.setBoolPreference(
        'scheduleDays${days[index].id}', days[index].selected);

    try {
      await syncAlarms();
    } catch (e) {
      debugPrint('Error syncing alarms: $e');
    }
  }

  Future<void> scheduleTime(TimeOfDay time) async {
    final replacingTime = time.replacing(hour: time.hour, minute: time.minute);

    _selectedTime = time;
    notifyListeners();
    String formattedTime = "${replacingTime.hour}:${replacingTime.minute}";

    await PreferencesService.setStringPreference(
        preferenceKeys[1], formattedTime);

    try {
      await syncAlarms();
    } catch (e) {
      debugPrint('Error syncing alarms: $e');
    }
  }

  Future<void> sliderScheduleVol(double val) async {
    await PreferencesService.setDoublePreference(preferenceKeys[2], val);
    _scheduleVol = val;
    notifyListeners();
  }

  Future<void> initDataFromPreferences() async {
    if (await PreferencesService.getBoolPreference(preferenceKeys[0]) != null) {
      _scheduleSwitch =
          await PreferencesService.getBoolPreference(preferenceKeys[0]) ??
              false;
    }

    for (int i = 0; i < _days.length; i++) {
      final bool? selected = await PreferencesService.getBoolPreference(
          'scheduleDays${_days[i].id}');
      if (selected == false) {
        _days[i] =
            DayItem(_days[i].id, _days[i].hebName, _days[i].engName, false);
      }
    }

    final scheduleTimeString =
        await PreferencesService.getStringPreference(preferenceKeys[1]);
    if (scheduleTimeString != null) {
      String t = scheduleTimeString;
      _selectedTime = TimeOfDay(
          hour: int.parse(t.split(":")[0]), minute: int.parse(t.split(":")[1]));
    }

    final scheduleVol =
        await PreferencesService.getDoublePreference(preferenceKeys[2]);
    if (scheduleVol != null) {
      _scheduleVol = scheduleVol;
    }
  }

  Future<bool> backgroundPermissions(bool service) async {
    if (!service) return true; // turning OFF never needs permission

    try {
      // 1. Check Battery Optimization status.
      bool? isOptimized =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      if (isOptimized == false) {
        await DisableBatteryOptimization
            .showDisableBatteryOptimizationSettings();
      }

      // 2. Check System Alert Window permission
      var overlayStatus = await Permission.systemAlertWindow.status;
      if (!overlayStatus.isGranted) {
        await Permission.systemAlertWindow.request();
      }

      // 3. Check Alarm permission (Android 12+)
      var alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }

      return (isOptimized ?? false) &&
          overlayStatus.isGranted &&
          alarmStatus.isGranted;
    } on Exception catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }
}
