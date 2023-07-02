import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_timer_app/providers/timer_provider.dart';

import '../../alertdialogs/scheduler_dialog.dart';
import '../../providers/channels_provider.dart';
import '../../alertdialogs/timer_dialog.dart';
import '../../providers/day_schedule.dart';

class DetailPlayerAppbar extends StatefulWidget {
  const DetailPlayerAppbar({Key? key}) : super(key: key);

  @override
  State<DetailPlayerAppbar> createState() => _DetailPlayerAppbarState();
}

class _DetailPlayerAppbarState extends State<DetailPlayerAppbar> {
  IconButton _iconButtonWidget(BuildContext context, IconData icon, Color color,
      double size, Function onTapFunc) {
    return IconButton(
        onPressed: () => onTapFunc(),
        icon: Icon(icon),
        iconSize: size,
        color: color);
  }

  @override
  Widget build(BuildContext context) {
    final channelsList = Provider.of<ChannelsProvider>(context);
    final channelData = channelsList.loadedChannel;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      child: Container(
        color: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 3),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              _iconButtonWidget(
                  context,
                  channelData.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  channelData.isFavorite ? Colors.red : Colors.white,
                  32, () {
                setState(() {
                  channelData.toggleFavoriteStatus(channelData.id);
                });
              }),
              const SizedBox(
                width: 18,
              ),
              if (Platform.isAndroid)
                Consumer<DaysSchedule>(
                  builder: (context, scheduleDays, child) {
                    return _iconButtonWidget(
                        context,
                        Icons.alarm,
                        (scheduleDays.scheduleSwitch)
                            ? Colors.green
                            : Colors.white,
                        32,
                        () => showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (ctx) => ScheduleDialog(channelsList)));
                  },
                ),
              SizedBox(
                width: Platform.isIOS ? 0 : 18,
              ),
              Consumer<TimerProvider>(builder: (context, timerProvider, child) {
                return _iconButtonWidget(
                    context,
                    (timerProvider.time > 0)
                        ? Icons.bedtime
                        : Icons.bedtime_outlined,
                    (timerProvider.time > 0) ? Colors.indigo : Colors.white,
                    32, () async {
                  final dialog = await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (ctx) => TimerDialog(
                            timerProvider.time,
                          )); //Timer

                  if (dialog == null) {
                    return;
                  }

                  if (dialog == 0) {
                    timerProvider.mytimer.cancel();
                    timerProvider.timerRunning = false;
                  } else {
                    timerProvider.timer(channelsList);
                  }
                  setState(() {
                    timerProvider.time = dialog;
                  });
                });
              }),
            ]),
            _iconButtonWidget(context, Icons.arrow_downward, Colors.white, 35,
                () => Navigator.of(context).pop()),
          ]),
        ),
      ),
    );
  }
}
