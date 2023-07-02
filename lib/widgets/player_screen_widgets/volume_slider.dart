import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({Key? key}) : super(key: key);

  @override
  SliderState createState() => SliderState();
}

class SliderState extends State<VolumeSlider> {
  bool _changingVolume = false;
  double _val = 0.5;

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initVolumeState();
  }

  //init volume_control plugin
  Future<void> initVolumeState() async {
    VolumeController().showSystemUI = false;

    //read the current volume
    final double initVol = await VolumeController().getVolume();
    _setVol(initVol);

    VolumeController().listener((volume) async {
      //listener
      _setVol(volume);
    });
  }

  void _setVol(double volume) async {
    if (_changingVolume) {
      return;
    }

    _changingVolume = true;
    setState(() {
      _val = volume;
    });

    VolumeController().setVolume(volume);

    Future.delayed(const Duration(milliseconds: 70), () {
      _changingVolume = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.volume_up),
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: Slider.adaptive(
                  value: _val,
                  min: 0,
                  max: 1,
                  divisions: 12,
                  onChanged: (val) {
                    _setVol(val);
                  }),
            ),
          ),
          const Icon(Icons.volume_down),
        ],
      ),
    );
  }
}
