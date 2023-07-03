import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/channel.dart';
import '../../providers/channels_provider.dart';
import './item_image_widget.dart';
import 'like_animation.dart';

class ChannelsGridItem extends StatelessWidget {
  final bool showingFavorite;
  final Function onChannelClick;

  const ChannelsGridItem(this.showingFavorite, this.onChannelClick, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channelData = context.read<Channel>();
    final channelsProvider = context.read<ChannelsProvider>();

    late void Function() toggleFavoriteHandler;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
          onTap: channelsProvider.playerLoading
              ? null
              : () => onChannelClick(channelData),
          onLongPress: () {
            channelData.toggleFavoriteStatus();
            toggleFavoriteHandler();
          },
          child: GridTile(
            footer: Container(
              color: Colors.black54,
              child: Text(
                channelData.title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    ItemImageWidget(channelData: channelData),
                    LikeAnimation(60, builder: (context, runAnimation) {
                      toggleFavoriteHandler = runAnimation;
                    })
                  ],
                )),
          )),
    );
  }
}
