import 'package:flutter_test/flutter_test.dart';
import 'package:radio_timer_app/models/day.dart';
import 'package:radio_timer_app/services/alarm_service.dart';
import 'package:flutter/material.dart'; // Import this if your function uses TimeOfDay

void main() {
  test('Test getSelectedWeekdays', () {
    final List<DayItem> days = [
      const DayItem(7, 'א', 'Sunday', true),
      const DayItem(1, 'ב', 'Monday', true),
      const DayItem(2, 'ג', 'Tuesday', true),
      const DayItem(3, 'ד', 'Wednesday', true),
      const DayItem(4, 'ה', 'Thursday', true),
      const DayItem(5, 'ו', 'Friday', false),
      const DayItem(6, 'ש', 'Saturday', true)
    ];

    const selectedTime = TimeOfDay(hour: 20, minute: 30);

    final result = AlarmService.getSelectedWeekdays(days, selectedTime);

    expect(result.length, 6); // You are expecting the next 6 days

    // Replace the assertions below with your expected results
    expect(result[0].weekday, DateTime.sunday);
    expect(result[1].weekday, DateTime.monday);
    expect(result[2].weekday, DateTime.tuesday);
    expect(result[3].weekday, DateTime.wednesday);
    expect(result[4].weekday, DateTime.thursday);
    expect(result[5].weekday, DateTime.saturday);

    // Check if the date is one week ahead if necessary
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    for (int i = 0; i < result.length; i++) {
      final daysToAdd = result[i].weekday - now.weekday;
      final nextDateTime = now.add(Duration(days: daysToAdd));

      if (daysToAdd < 0 || (daysToAdd == 0 && now.isAfter(selectedDateTime))) {
        expect(result[i].day, nextDateTime.add(const Duration(days: 7)).day);
      } else {
        expect(result[i].day, nextDateTime.day);
      }
    }
  });
}
