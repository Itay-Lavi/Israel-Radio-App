import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  SliderState createState() => SliderState();
}

class SliderState extends State<VolumeSlider> {
  bool _userChanging = false;
  double _val = 0.5;

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initVolume();
  }

  Future<void> _initVolume() async {
    VolumeController.instance.showSystemUI = false;
    _updateUi(await VolumeController.instance.getVolume());
    VolumeController.instance.addListener(_updateUi);
  }

  void _updateUi(double volume) {
    if (_userChanging || !mounted) return;
    setState(() => _val = volume);
  }

  void _onSliderChanged(double value) {
    if (!mounted) return;
    _userChanging = true;
    setState(() => _val = value);
    VolumeController.instance.setVolume(value);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _userChanging = false;
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
                onChanged: _onSliderChanged,
              ),
            ),
          ),
          const Icon(Icons.volume_down),
        ],
      ),
    );
  }
}
