// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
// import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:radio_timer_app/models/day.dart';

class AlarmService {
  // late FlutterAlarmBackgroundTrigger _alarmPlugin;

  AlarmService() {
    // _alarmPlugin = FlutterAlarmBackgroundTrigger();
  }

  // void alarmEventHandler(void Function(List<AlarmItem>) func) {
  //   _alarmPlugin.onForegroundAlarmEventHandler(func);
  // }

  Future<void> updateAlarms(
      List<DayItem> days, TimeOfDay selectedTime, bool scheduleSwitch) async {
    await deleteAllAlarm();

    if (scheduleSwitch) {
      List<DateTime> selectedWeekdays = getSelectedWeekdays(days, selectedTime);
      addAlarms(selectedWeekdays);
    }
  }

  // Future<List<AlarmItem>> getAllAlarms() async {
  //   return await _alarmPlugin.getAllAlarms();
  // }

  Future<void> addAlarms(List<DateTime> selectedDates) async {
    for (final datetime in selectedDates) {
      // await _alarmPlugin.addAlarm(datetime);
    }
  }

  Future<void> deleteAllAlarm() async {
    // final allAlarms = await _alarmPlugin.getAllAlarms();
    // for (final alarm in allAlarms) {
    //   await _alarmPlugin.deleteAlarm(alarm.id!);
    // }
  }

  // Future<bool> requestPermission() async {
  //   return await _alarmPlugin.requestPermission();
  // }

  static List<DateTime> getSelectedWeekdays(
      List<DayItem> days, TimeOfDay selectedTime) {
    List<DateTime> selectedWeekdays = [];

    for (final day in days) {
      if (!day.selected) continue;

      DateTime dateTime = DateTime.now();
      int daysToAdd = 0;

      DateTime selectedTimeDate = DateTime(dateTime.year, dateTime.month,
          dateTime.day, selectedTime.hour, selectedTime.minute);

      // Calculate days to add based on selected weekday
      daysToAdd = day.id - dateTime.weekday;
      if (daysToAdd < 0 ||
          (daysToAdd == 0 && dateTime.isAfter(selectedTimeDate))) {
        daysToAdd += 7;
      }

      dateTime = dateTime.add(Duration(days: daysToAdd));
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
          selectedTime.hour, selectedTime.minute);
      selectedWeekdays.add(dateTime);
    }

    return selectedWeekdays;
  }
}
