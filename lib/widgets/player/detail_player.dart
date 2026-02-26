// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/channels_provider.dart';
import '../../providers/ui_provider.dart';
import 'volume_slider.dart';

class DetailPlayer extends StatefulWidget {
  const DetailPlayer({super.key});

  @override
  State<DetailPlayer> createState() => _DetailPlayerState();
}

class _DetailPlayerState extends State<DetailPlayer> {
  StreamSubscription<(Object, StackTrace)>? _errorSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _errorSub?.cancel();
    final channelsProvider = context.read<ChannelsProvider>();
    final uiProvider = context.read<UiProvider>();
    _errorSub = channelsProvider.errorStream.listen((record) {
      final (error, stackTrace) = record;
      uiProvider.showErrorToast(error: error, stackTrace: stackTrace);
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    super.dispose();
  }

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
    final uiProvider = context.read<UiProvider>();

    return ClipRRect(
      //player at bottom
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50), topRight: Radius.circular(50)),
      child: Container(
        height: 150,
        color: Colors.black26,
        child: Column(
          children: [
            Consumer<ChannelsProvider>(builder: (context, channelsProvider, _) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconButtonWidget(
                        context,
                        Icons.skip_previous,
                        Colors.white,
                        45,
                        () => channelsProvider.moveChannels(-1).onError(
                            (e, st) => uiProvider.showErrorToast(
                                error: e, stackTrace: st))),
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
                            () => channelsProvider.playOrPause().onError(
                                (e, st) => uiProvider.showErrorToast(
                                    error: e, stackTrace: st))),
                    const SizedBox(width: 10),
                    _iconButtonWidget(
                        context,
                        Icons.skip_next,
                        Colors.white,
                        45,
                        () => channelsProvider.moveChannels(1).onError(
                            (e, st) => uiProvider.showErrorToast(
                                error: e, stackTrace: st))),
                  ]);
            }),
            const VolumeSlider(),
          ],
        ),
      ),
    );
  }
}
