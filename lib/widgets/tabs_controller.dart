// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_timer_app/providers/ui_provider.dart';

import '../providers/channels_provider.dart';
import '../providers/day_schedule.dart';
import '../screens/tabs_screen.dart';

// ignore: must_be_immutable
class TabsController extends StatelessWidget {
  const TabsController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channels = context.read<ChannelsProvider>();
    context.read<DaysSchedule>().initData(channels);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(90),
            child: AppBar(
                bottom: TabBar(
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('כל התחנות'),
                          SizedBox(width: 10),
                          Icon(Icons.radio),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('מעודפים'),
                          SizedBox(width: 10),
                          Icon(Icons.favorite),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: const Text(
                  'רדיו ישראל',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
                leading: Consumer<UiProvider>(
                  builder: (ctx, uiProvider, _) {
                    uiProvider.initViewType();
                    return IconButton(
                        onPressed: uiProvider.switchViewType,
                        icon: Icon(
                          uiProvider.viewType == ViewType.list
                              ? Icons.grid_on
                              : Icons.list_alt,
                          size: 27,
                        ));
                  },
                )),
          ),
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ]),
              ),
            ),
            TabsScreen(channels)
          ]),
        ));
  }
}
