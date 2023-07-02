import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/channel_item.dart';
import '../providers/channels_provider.dart';

class ChannelsList extends StatelessWidget {
  final bool showFavs;
  final Function errorSnackBar;

  const ChannelsList(this.showFavs, this.errorSnackBar, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channels = Provider.of<ChannelsProvider>(context);
    final channelsList = showFavs ? channels.favoriteItems : channels.channels;
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
        itemBuilder: (ctx, i) {
          return ChangeNotifierProvider.value(
            value: channelsList[i],
            child: ChannelsListItem(showFavs, errorSnackBar),
          );
        },
        itemCount: channelsList.length);
  }
}
