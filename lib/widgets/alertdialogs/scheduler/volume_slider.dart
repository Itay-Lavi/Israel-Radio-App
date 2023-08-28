import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/day_schedule.dart';

class SchedulerVolumeSlider extends StatelessWidget {
  const SchedulerVolumeSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleVol =
        context.select<DaysSchedule, double>((prov) => prov.scheduleVol);
    return Column(
      children: [
        const Divider(thickness: 2),
        Text('עוצמת הפעלה - ${(scheduleVol * 100).toStringAsFixed(0)}'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RotatedBox(
            quarterTurns: 2,
            child: Slider(
              value: scheduleVol,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: context.read<DaysSchedule>().sliderScheduleVol,
            ),
          ),
        ),
      ],
    );
  }
}
