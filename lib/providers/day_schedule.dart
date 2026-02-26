import 'dart:async';

import 'package:flutter/material.dart';

// import 'package:move_to_background/move_to_background.dart';
import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:radio_timer_app/services/alarm_service.dart';
import 'package:volume_controller/volume_controller.dart';

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

  final AlarmService _alarmService = AlarmService();

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
    await initDataFromPreferences();

    // _alarmService.alarmEventHandler((alarms) async {
    //   await Future.delayed(const Duration(seconds: 5));
    //   VolumeController.instance.setVolume(scheduleVol);
    //   channelsProv.playOrPause(true);
    //   // MoveToBackground.moveTaskToBack();
    //   _alarmService.updateAlarms(_days, selectedTime, scheduleSwitch);
    // });

    notifyListeners();
  }

  Future<void> toggleMainSwitch(bool mainSwitch) async {
    final bool permisssion = await backgroundPermissions(mainSwitch);
    if (!permisssion) {
      return;
    }

    _scheduleSwitch = mainSwitch;
    notifyListeners();
    await _alarmService.updateAlarms(_days, selectedTime, scheduleSwitch);
    await PreferencesService.setBoolPreference(
        preferenceKeys[0], scheduleSwitch);
  }

  Future<void> toggleSelectedDay(int id) async {
    final index = _days.indexWhere((e) => e.id == id);
    _days[index] = DayItem(
        id, _days[index].hebName, _days[index].engName, !_days[index].selected);
    notifyListeners();
    await _alarmService.updateAlarms(_days, selectedTime, scheduleSwitch);

    await PreferencesService.setBoolPreference(
        'scheduleDays${days[index].id}', days[index].selected);
  }

  Future<void> scheduleTime(TimeOfDay time) async {
    final replacingTime = time.replacing(hour: time.hour, minute: time.minute);

    _selectedTime = time;
    notifyListeners();
    await _alarmService.updateAlarms(_days, selectedTime, scheduleSwitch);
    String formattedTime = "${replacingTime.hour}:${replacingTime.minute}";

    await PreferencesService.setStringPreference(
        preferenceKeys[1], formattedTime);
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
    try {
      if (service) {
        await DisableBatteryOptimizationLatest
            .showDisableBatteryOptimizationSettings();
        // final alarmPermission = await _alarmService.requestPermission();
        // if (!alarmPermission) {
        //   return false;
        // }
      }
      return true;
    } on Exception {
      return false;
    }
  }
}
