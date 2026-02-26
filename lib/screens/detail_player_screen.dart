import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../models/channel.dart';
import '../providers/channels_provider.dart';
import '../widgets/player/detail_player.dart';
import '../widgets/player/detail_player_appbar.dart';

class DetailPlayerScreen extends StatelessWidget {
  const DetailPlayerScreen({Key? key}) : super(key: key);

  static const routeName = '/player-screen';

  Image _imageWidget(Channel channelData) {
    return Image(
      image: CachedNetworkImageProvider(
        channelData.imageUrl,
        scale: 0.5,
      ),
      fit: BoxFit.cover,
    );
  }

  MiniMusicVisualizer _musicVisualizer(BuildContext context) {
    return MiniMusicVisualizer(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      width: 20,
      height: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
      children: [
        Consumer<ChannelsProvider>(builder: (context, channelsProvider, _) {
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          channelsProvider.loadedChannel.imageUrl),
                      fit: BoxFit.fill,
                      scale: 2)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox.expand(),
              ));
        }),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const DetailPlayerAppbar(), //PlayerAppBar
            Consumer<ChannelsProvider>(builder: (context, channelsProvider, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Card(
                  elevation: 5,
                  child: !channelsProvider.play
                      ? _imageWidget(channelsProvider.loadedChannel)
                      : SizedBox(
                          width: 400,
                          child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                (_imageWidget(channelsProvider.loadedChannel)),
                                FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 0; i <= 3; i++)
                                        _musicVisualizer(context),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                ),
              );
            }),

            const DetailPlayer()
          ],
        ),
      ],
    )));
  }
}
