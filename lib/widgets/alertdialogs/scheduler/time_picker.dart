import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_timer_app/providers/day_schedule.dart';

class SchedulerTimePicker extends StatelessWidget {
  const SchedulerTimePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTime =
        context.select<DaysSchedule, TimeOfDay>((prov) => prov.selectedTime);

    return Column(
      children: [
        Text(
          'הרדיו ידלק ב ${selectedTime.format(context)}',
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        TextButton(
            onPressed: () async {
              final TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                initialEntryMode: TimePickerEntryMode.dial,
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
                cancelText: 'ביטול',
                confirmText: 'אוקיי',
                hourLabelText: 'שעות',
                minuteLabelText: 'דקות',
                helpText: 'בחר שעה',
              );

              if (timeOfDay != null && timeOfDay != selectedTime) {
                // ignore: use_build_context_synchronously
                context.read<DaysSchedule>().scheduleTime(timeOfDay);
              }
            },
            child: const Text('הגדר שעה', style: TextStyle(fontSize: 18))),
      ],
    );
  }
}
