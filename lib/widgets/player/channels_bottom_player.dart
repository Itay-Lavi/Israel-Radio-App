import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../../providers/ui_provider.dart';
import '../../screens/detail_player_screen.dart';
import '../../models/channel.dart';
import '../../providers/channels_provider.dart';

class ChannelsBottomPlayer extends StatefulWidget {
  const ChannelsBottomPlayer({super.key});

  @override
  State<ChannelsBottomPlayer> createState() => _ChannelsBottomPlayerState();
}

class _ChannelsBottomPlayerState extends State<ChannelsBottomPlayer> {
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

  @override
  Widget build(BuildContext context) {
    final channelsProvider = context.watch<ChannelsProvider>();
    final uiProvider = context.read<UiProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          DetailPlayerScreen.routeName,
        ),
        child: Card(
          margin: const EdgeInsets.only(bottom: 3),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color:
              const Color.fromARGB(255, 107, 119, 202).withValues(alpha: 0.9),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                channelsProvider.playerLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CircularProgressIndicator(
                            color: Colors.white.withValues(alpha: 0.85)))
                    : IconButton(
                        onPressed: () async {
                          try {
                            await channelsProvider.playOrPause();
                          } catch (err, st) {
                            uiProvider.showErrorToast(
                                error: err, stackTrace: st);
                          }
                        },
                        icon: Icon(channelsProvider.play
                            ? Icons.pause_circle
                            : Icons.play_circle),
                        color: Colors.white.withValues(alpha: 0.85),
                        splashColor: Colors.white54,
                        splashRadius: 38,
                        iconSize: 53,
                      ),
                if (!channelsProvider.playerLoading && channelsProvider.play)
                  const MiniMusicVisualizer(
                    color: Colors.white54,
                    width: 7,
                    height: 20,
                    animate: true,
                  )
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                channelsProvider.loadedChannel.title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                width: 10,
              ),
              ClipOval(
                child: Container(
                    color: Colors.white,
                    height: 70,
                    width: 70,
                    child: Image(
                      image: CachedNetworkImageProvider(
                          channelsProvider.loadedChannel.imageUrl),
                      fit: BoxFit.cover,
                    )),
              ),
            ])
          ]),
        ),
      ),
    );
  }
}
