import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/channel.dart';
import '../providers/ui_provider.dart';
import '../providers/channels_provider.dart';
import '../widgets/channels/grid_item.dart';
import '../widgets/channels/list_item.dart';
import './detail_player_screen.dart';

class ChannelsList extends StatelessWidget {
  final bool showFavs;

  const ChannelsList(this.showFavs, {super.key});

  @override
  Widget build(BuildContext context) {
    final uiProvider = context.watch<UiProvider>();
    final channelsProvider = context.watch<ChannelsProvider>();
    final channelsList =
        showFavs ? channelsProvider.favoriteItems : channelsProvider.channels;

    void channelClickHandler(Channel channelData) async {
      try {
        if (channelsProvider.loadedChannel != channelData) {
          channelsProvider.updatePlayerLoading(true);
          await channelsProvider.setChannel(channelData, true);
        } else if (channelsProvider.loadedChannel == channelData &&
            !channelsProvider.play) {
          await channelsProvider.playOrPause();
        } else {
          () => Navigator.of(context).pushNamed(
                DetailPlayerScreen.routeName,
              );
        }
      } catch (e, st) {
        uiProvider.showErrorToast(error: e, stackTrace: st);
      } finally {
        channelsProvider.updatePlayerLoading(false);
      }
    }

    final double bottomPadding = 80 + MediaQuery.of(context).padding.bottom;

    return uiProvider.viewType == ViewType.list
        ? ListView.builder(
            padding: EdgeInsets.fromLTRB(10, 10, 10, bottomPadding),
            itemBuilder: (ctx, i) {
              return ChangeNotifierProvider.value(
                value: channelsList[i],
                child: ChannelsListItem(showFavs, channelClickHandler),
              );
            },
            itemCount: channelsList.length)
        : GridView.builder(
            padding: EdgeInsets.fromLTRB(10, 10, 10, bottomPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemBuilder: (ctx, i) {
              return ChangeNotifierProvider.value(
                value: channelsList[i],
                child: ChannelsGridItem(showFavs, channelClickHandler),
              );
            },
            itemCount: channelsList.length);
  }
}
