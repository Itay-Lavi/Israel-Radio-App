import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../screens/detail_player_screen.dart';
import '../models/channel.dart';
import '../providers/channels_provider.dart';

// ignore: must_be_immutable
class ChannelsBottomPlayer extends StatelessWidget {
  ChannelsBottomPlayer({Key? key}) : super(key: key);

  void showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.error,
      content: const Text(
        'שגיאת אינטרנט',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
      duration: const Duration(seconds: 4),
    ));
  }

  late List<Channel> channelsList;

  @override
  Widget build(BuildContext context) {
    final channelsProvider = Provider.of<ChannelsProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: channelsProvider.playerLoading
            ? null
            : () => Navigator.of(context).pushNamed(
                  DetailPlayerScreen.routeName,
                ),
        child: Card(
          margin: const EdgeInsets.only(bottom: 3),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: const Color.fromARGB(255, 107, 119, 202).withOpacity(0.9),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                channelsProvider.playerLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.85)))
                    : IconButton(
                        onPressed: () async {
                          try {
                            await channelsProvider.playOrPause();
                          } catch (err) {
                            showSnackBar(context);
                          }
                        },
                        icon: Icon(channelsProvider.play
                            ? Icons.pause_circle
                            : Icons.play_circle),
                        color: Colors.white.withOpacity(0.85),
                        splashColor: Colors.white54,
                        splashRadius: 38,
                        iconSize: 53,
                      ),
                if (!channelsProvider.playerLoading && channelsProvider.play)
                  const MiniMusicVisualizer(
                    color: Colors.white54,
                    width: 7,
                    height: 20,
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
