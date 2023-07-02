import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/detail_player_screen.dart';
import '../models/channel.dart';
import '../providers/channels_provider.dart';

class ChannelsListItem extends StatelessWidget {
  final bool showingFavorite;
  final Function showSnackBar;
  const ChannelsListItem(this.showingFavorite, this.showSnackBar, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channelData = Provider.of<Channel>(context, listen: false);
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    return GestureDetector(
      onTap: channelsProvider.playerLoading
          ? null
          : () async {
              try {
                if (channelsProvider.loadedChannel != channelData) {
                  channelsProvider.updatePlayerLoading(true);
                  await channelsProvider.setChannel(channelData, true);
                  channelsProvider.updatePlayerLoading(false);
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed(DetailPlayerScreen.routeName);
              } catch (e) {
                showSnackBar();
              }
            },
      child: SizedBox(
        height: showingFavorite ? 120 : 85,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<Channel>(builder: (_, channel, child) {
                  return IconButton(
                    icon: channel.isFavorite
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 28,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            color: Colors.black54,
                            size: 28,
                          ),
                    onPressed: () => channel.toggleFavoriteStatus(channel.id),
                  );
                }),
                Expanded(
                  child: Text(
                    channelData.title,
                    textAlign: TextAlign.end,
                    softWrap: true,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 1000),
                    fadeInCurve: Curves.easeIn,
                    image: CachedNetworkImageProvider(
                      channelData.imageUrl,
                    ),
                    placeholder:
                        const AssetImage('assets/images/Radio-Placeholder.png'),
                    imageErrorBuilder: (_, __, ___) {
                      return const Image(
                          image: AssetImage(
                              'assets/images/Radio-Placeholder.png'));
                    },
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
