import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/day.dart';
import '../../../providers/day_schedule.dart';

class DaysListPicker extends StatelessWidget {
  const DaysListPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days =
        context.select<DaysSchedule, List<DayItem>>((prov) => prov.days);

    return SizedBox(
      width: double.maxFinite,
      height: 45,
      child: Center(
        child: ListView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: days.map((daydata) {
            return Container(
                height: 36,
                width: 36,
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      backgroundColor:
                          daydata.selected ? Colors.indigo : Colors.grey),
                  child: Text(
                    daydata.hebName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context
                      .read<DaysSchedule>()
                      .toggleSelectedDay(daydata.id),
                ));
          }).toList(),
        ),
      ),
    );
  }
}
