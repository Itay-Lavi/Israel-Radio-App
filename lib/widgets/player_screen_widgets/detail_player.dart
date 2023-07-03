import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'volume_slider.dart';
import '../../providers/channels_provider.dart';

class DetailPlayer extends StatefulWidget {
  const DetailPlayer({Key? key}) : super(key: key);

  @override
  State<DetailPlayer> createState() => _DetailPlayerState();
}

class _DetailPlayerState extends State<DetailPlayer> {
  IconButton _iconButtonWidget(BuildContext context, IconData icon, Color color,
      double size, Function onTapFunc) {
    return IconButton(
        onPressed: () => onTapFunc(),
        icon: Icon(icon),
        iconSize: size,
        color: color);
  }

  void showErrorSnackBar(BuildContext context,
      [String text = 'שגיאת אינטרנט']) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final channelsProvider = Provider.of<ChannelsProvider>(context);
    return ClipRRect(
      //player at bottom
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50), topRight: Radius.circular(50)),
      child: Container(
        height: 150,
        color: Colors.black26,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _iconButtonWidget(
                  context,
                  Icons.skip_previous,
                  Colors.white,
                  45,
                  () => channelsProvider
                      .moveChannels(-1)
                      .onError((__, _) => showErrorSnackBar(context))),
              const SizedBox(width: 10),
              channelsProvider.playerLoading
                  ? const Padding(
                      padding: EdgeInsets.all(25),
                      child: CircularProgressIndicator())
                  : _iconButtonWidget(
                      context,
                      channelsProvider.play
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      Theme.of(context).colorScheme.secondary,
                      70,
                      () => channelsProvider
                          .playOrPause()
                          .onError((__, _) => showErrorSnackBar(context))),
              const SizedBox(width: 10),
              _iconButtonWidget(
                  context,
                  Icons.skip_next,
                  Colors.white,
                  45,
                  () => channelsProvider
                      .playOrPause()
                      .onError((__, _) => showErrorSnackBar(context))),
            ]),
            const VolumeSlider(),
          ],
        ),
      ),
    );
  }
}
