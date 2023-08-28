import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/day_schedule.dart';
import '../../../providers/channels_provider.dart';
import 'days_list_picker.dart';
import 'time_picker.dart';
import 'volume_slider.dart';

// ignore: must_be_immutable
class ScheduleDialog extends StatelessWidget {
  ChannelsProvider channelsList;
  ScheduleDialog(this.channelsList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleSwitch =
        context.select<DaysSchedule, bool>((prov) => prov.scheduleSwitch);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Container(
        height: 50,
        decoration: const BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        child: const Center(
          child: Text(
            'שעון רדיו מעורר',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
      ),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: 400,
        height: 290,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                    activeColor: Colors.indigoAccent,
                    value: scheduleSwitch,
                    onChanged: context.read<DaysSchedule>().toggleMainSwitch),
                const Text('סטטוס')
              ],
            ),
            !scheduleSwitch
                ? const Text('שעון מעורר לא פעיל')
                : const Column(
                    children: [
                      Divider(thickness: 2),
                      SchedulerTimePicker(),
                      DaysListPicker(),
                      SchedulerVolumeSlider()
                    ],
                  )
          ],
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text(
                    'סגור',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
