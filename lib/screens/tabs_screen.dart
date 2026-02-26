import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_timer_app/screens/error_screen.dart';

import '../providers/channels_provider.dart';
import '../widgets/player/channels_bottom_player.dart';
import './channels_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    final channelsProv = context.read<ChannelsProvider>();
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary
            ],
          ),
        ),
      ),
      FutureBuilder(
          future: channelsProv.initData(),
          builder: (ctx, chanSnapShot) {
            if (chanSnapShot.hasError) {
              if (chanSnapShot.error.toString().contains('SocketException')) {
                return const ErrorScreen(
                    true); //Return error screen widget with internet error message
              }
              return const ErrorScreen(
                  false); //Return error screen widget with general error message
            }
            return chanSnapShot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      const TabBarView(
                        children: [
                          ChannelsList(false), //כל התחנות
                          ChannelsList(true), //מעודפים
                        ],
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: chanSnapShot.connectionState ==
                                  ConnectionState.waiting
                              ? Container()
                              : ChannelsBottomPlayer()),
                    ],
                  );
          })
    ]);
  }
}
