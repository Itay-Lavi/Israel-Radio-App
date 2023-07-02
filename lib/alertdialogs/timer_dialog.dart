import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

// ignore: must_be_immutable
class TimerDialog extends StatefulWidget {
  int time;

  TimerDialog(this.time, {Key? key}) : super(key: key);

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  @override
  Widget build(BuildContext context) {
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
            'טיימר',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
      ),
      titlePadding: const EdgeInsets.all(0),
      content: SleekCircularSlider(
        min: 0,
        max: 120,
        initialValue: widget.time.toDouble(),
        innerWidget: (value) {
          return Center(
              child: Text(
            '${value.toStringAsFixed(0)} דק\'',
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 25),
          ));
        },
        appearance: CircularSliderAppearance(
            customColors: CustomSliderColors(
              trackColor: Colors.indigo,
            ),
            size: 200),
        onChange: (value) {
          widget.time = value.round();
        },
      ),
      actions: <Widget>[
        Column(
          children: [
            (widget.time > 0)
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.time = 0;
                      });
                      Timer(const Duration(seconds: 1), () {
                        Navigator.of(context).pop(0);
                      });
                    },
                    child: const Text('כבה טיימר'))
                : Container(),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'סגור',
                    )),
                TextButton(
                    child: const Text('שמור'),
                    onPressed: () {
                      Navigator.of(context).pop(widget.time);
                    }),
              ],
            ),
          ],
        )
      ],
    );
  }
}
