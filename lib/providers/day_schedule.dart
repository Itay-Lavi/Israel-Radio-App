import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';

import './channels_provider.dart';
import '../models/day.dart';

void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  // FlutterForegroundTask.setTaskHandler();
}

class DaysSchedule with ChangeNotifier {
  bool timerRunning = false;
  bool scheduleSwitch = false;
  double scheduleVol = 0.5;
  TimeOfDay selectedTime = TimeOfDay.now();
  Timer? scheduleTimer;
  //bool _foregroundServiceRunning = false;

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

  Future<void> initData(ChannelsProvider channelsList) async {
    //Initialize data from saved data

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('scheduleSwitch') != null) {
      toggleMainSwitch(prefs.getBool('scheduleSwitch')!, channelsList);
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
    notifyListeners();
  }

  Future<void> toggleMainSwitch(
    bool val,
    ChannelsProvider channelsList,
  ) async {
    //MainSwitch

    final bool permisssion = await backgroundExecute(val);
    if (!permisssion) {
      return;
    }

    if (val) {
      timer(channelsList);
    } else {
      if (scheduleTimer != null) {
        scheduleTimer!.cancel();
      }
    }
    scheduleSwitch = val;
    final prefs = await SharedPreferences.getInstance(); //Save Switch State
    await prefs.setBool('scheduleSwitch', scheduleSwitch);
    notifyListeners();
  }

  Future<void> sliderScheduleVol() async {
    //Save sliderScheduleVol
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

  void timer(ChannelsProvider channelsProvider) {
    scheduleTimer = Timer.periodic(const Duration(seconds: 7), (mytimer) {
      TimeOfDay deviceTime = TimeOfDay.now();
      DateTime date = DateTime.now();
      String weekdayNow = DateFormat('EEEE').format(date).toString();

      for (int i = 0; i < _days.length; i++) {
        if ((_days[i].checked == true) &
            (weekdayNow == _days[i].backendDay) &
            (selectedTime == deviceTime)) {
          VolumeController().setVolume(scheduleVol);
          if (!channelsProvider.play) {
            channelsProvider.playOrPause();
          }
        }
      }
    });
  }

  Future<bool> backgroundExecute(bool service) async {
    try {
      if (service) {
        final batOptimization =
            await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        if (!batOptimization) {
          return false;
        }

        final serviceIsRunnning = await FlutterForegroundTask.isRunningService;
        if (!serviceIsRunnning) {
          await FlutterForegroundTask.startService(
              notificationTitle: "רדיו ישראל",
              notificationText: "שעון רדיו מעורר רץ ברקע");
        }
      } else {
        await FlutterForegroundTask.stopService();
      }
      return true;
    } on Exception {
      await FlutterForegroundTask.restartService();
      return false;
    }
  }
}
