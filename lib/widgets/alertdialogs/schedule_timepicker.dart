import 'package:flutter/material.dart';
import 'package:radio_timer_app/providers/day_schedule.dart';

// ignore: must_be_immutable
class TimePicker extends StatefulWidget {
  DaysSchedule checkDays;
  TimePicker(this.checkDays, {Key? key}) : super(key: key);

  @override
  TimePickerState createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  @override
  Widget build(BuildContext context) {
    final checkDaysList = widget.checkDays.days.toList();
    return Column(
      children: [
        const Divider(thickness: 2),
        Text(
          'הרדיו ידלק ב ${widget.checkDays.selectedTime.format(context)}',
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        TextButton(
            onPressed: () async {
              final TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: widget.checkDays.selectedTime,
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

              if (timeOfDay != null &&
                  timeOfDay != widget.checkDays.selectedTime) {
                setState(() {
                  widget.checkDays.selectedTime = timeOfDay;
                  widget.checkDays.scheduleTime(context);
                });
              }
            },
            child: const Text('הגדר שעה', style: TextStyle(fontSize: 18))),
        SizedBox(
          width: double.maxFinite,
          height: 45,
          child: Center(
            child: ListView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: checkDaysList.map((daysdata) {
                return Container(
                  height: 36,
                  width: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        backgroundColor:
                            daysdata.checked ? Colors.indigo : Colors.grey),
                    child: Text(
                      daysdata.frontedDay,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      setState(() {
                        daysdata.daycheckbox(daysdata.id);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(thickness: 2),
        Text(
            'עוצמת הפעלה - ${(widget.checkDays.scheduleVol * 100).toStringAsFixed(0)}'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RotatedBox(
            quarterTurns: 2,
            child: Slider(
              value: widget.checkDays.scheduleVol,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: (vol) {
                setState(() {
                  widget.checkDays.scheduleVol = vol;
                });
              },
              onChangeEnd: (_) {
                widget.checkDays.sliderScheduleVol();
              },
            ),
          ),
        ),
      ],
    );
  }
}
