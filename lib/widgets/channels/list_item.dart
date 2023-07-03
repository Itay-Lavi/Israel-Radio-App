import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/channel.dart';
import '../../providers/channels_provider.dart';

class ChannelsListItem extends StatelessWidget {
  final bool showingFavorite;
  final Function onChannelClick;

  const ChannelsListItem(this.showingFavorite, this.onChannelClick, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channelData = context.read<Channel>();
    final channelsProvider = context.read<ChannelsProvider>();

    return GestureDetector(
      onTap: channelsProvider.playerLoading
          ? null
          : () => onChannelClick(channelData),
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
                  return Stack(children: [
                    IconButton(
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
                        onPressed: channelData.toggleFavoriteStatus),
                  ]);
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
