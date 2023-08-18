import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock/wakelock.dart';

import './channels_provider.dart';
import '../models/day.dart';

class DaysSchedule with ChangeNotifier {
  bool timerRunning = false;
  bool scheduleSwitch = false;
  double scheduleVol = 0.5;
  TimeOfDay selectedTime = TimeOfDay.now();
  final alarmPlugin = FlutterAlarmBackgroundTrigger();

  final List<DayItem> _days = [
    DayItem(0, 'א', 'Sunday', true),
    DayItem(1, 'ב', 'Monday', true),
    DayItem(2, 'ג', 'Tuesday', true),
    DayItem(3, 'ד', 'Wednesday', true),
    DayItem(4, 'ה', 'Thursday', true),
    DayItem(5, 'ו', 'Friday', true),
    DayItem(6, 'ש', 'Saturday', true)
  ];

  List<DayItem> get days {
    return [..._days];
  }

  Future<void> initData(ChannelsProvider channelsProv) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('scheduleSwitch') != null) {
      toggleMainSwitch(prefs.getBool('scheduleSwitch')!, channelsProv);
    }
    for (var day in _days) {
      if (prefs.getBool('scheduleDays${day.id}') == false) {
        day.checked = prefs.getBool('scheduleDays${day.id}')!;
      }
    }
    if (prefs.getString('scheduleTime') != null) {
      String t = prefs.getString('scheduleTime')!;
      selectedTime = TimeOfDay(
          hour: int.parse(t.split(":")[0]), minute: int.parse(t.split(":")[1]));
    }
    if (prefs.getDouble('scheduleVol') != null) {
      scheduleVol = prefs.getDouble('scheduleVol')!;
    }

    alarmPlugin.onForegroundAlarmEventHandler((alarm) async {
      VolumeController().setVolume(scheduleVol);
      await Future.delayed(const Duration(seconds: 5));
      channelsProv.playOrPause();
      Wakelock.disable();
    });
    notifyListeners();
  }

  Future<void> toggleMainSwitch(
    bool mainSwitch,
    ChannelsProvider channelsProvider,
  ) async {
    final bool permisssion = await backgroundPermissions(mainSwitch);
    if (!permisssion) {
      return;
    }

    final mainAlarm = await alarmPlugin.getAlarmByUid("main");
    if (mainSwitch && mainAlarm.isEmpty) {
      print('added alarm');
      alarmPlugin.addAlarm(DateTime.now().add(const Duration(minutes: 1)),
          uid: "main");
    } else if (!mainSwitch) {
      print('delete alarms');
      alarmPlugin.deleteAllAlarms();
    }
    scheduleSwitch = mainSwitch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scheduleSwitch', scheduleSwitch);
    notifyListeners();
  }

  Future<void> sliderScheduleVol() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scheduleVol', scheduleVol);
  }

  Future<void> scheduleTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var replacingTime = selectedTime.replacing(
        hour: selectedTime.hour, minute: selectedTime.minute);

    String formattedTime = "${replacingTime.hour}:${replacingTime.minute}";
    await prefs.setString('scheduleTime', formattedTime);
  }

  // void timer(ChannelsProvider channelsProvider) {
  //   scheduleTimer = Timer.periodic(const Duration(seconds: 60), (mytimer) {
  //     TimeOfDay deviceTime = TimeOfDay.now();
  //     DateTime date = DateTime.now();
  //     String weekdayNow = DateFormat('EEEE').format(date).toString();

  //     final bool isTimeMatch = selectedTime == deviceTime;

  //     for (int i = 0; i < _days.length; i++) {
  //       if ((_days[i].checked == true) &
  //           (weekdayNow == _days[i].backendDay) &
  //           isTimeMatch) {
  //         VolumeController().setVolume(scheduleVol);
  //         if (!channelsProvider.play) {
  //           channelsProvider.playOrPause();
  //         }
  //       }
  //     }
  //   });
  // }

  Future<bool> backgroundPermissions(bool service) async {
    try {
      if (service) {
        await OptimizeBattery.stopOptimizingBatteryUsage();

        final batOptimization =
            await OptimizeBattery.isIgnoringBatteryOptimizations();
        print('batOptimization $batOptimization');
        if (!batOptimization) {
          return false;
        }

        final alarmPermission = await alarmPlugin.requestPermission();
        if (!alarmPermission) {
          return false;
        }
      }
      return true;
    } on Exception {
      return false;
    }
  }
}
