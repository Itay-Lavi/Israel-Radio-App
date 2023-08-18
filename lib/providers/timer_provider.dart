import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'channels_provider.dart';

class TimerProvider with ChangeNotifier {
  late Timer mytimer;
  bool timerRunning = false;
  int time = 0;

  void timer(ChannelsProvider channelsProvider) {
    if (timerRunning) {
      return;
    }
    timerRunning = true;

    if (!channelsProvider.play) {
      channelsProvider.playOrPause();
    }
    mytimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (time > 0) {
        time--;
      } //using else will skip if time gets zero
      else if (time == 0) {
        timerRunning = false;
        timer.cancel();
        if (channelsProvider.play) {
          channelsProvider.playOrPause();
        }
      }
    });
  }
}
