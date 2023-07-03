import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:radio_timer_app/providers/ui_provider.dart';

import 'config/foreground_task.dart';
import 'screens/detail_player_screen.dart';
import './widgets/tabs_controller.dart';

import '../providers/timer_provider.dart';
import '../providers/day_schedule.dart';
import '../providers/channels_provider.dart';

main() {
  // WidgetsFlutterBinding.ensureInitialized();
  _initForegroundTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return WithForegroundTask(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => DaysSchedule()),
          ChangeNotifierProvider(create: (ctx) => TimerProvider()),
          ChangeNotifierProvider(create: (ctx) => UiProvider()),
          ChangeNotifierProvider(create: (ctx) => ChannelsProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'שעון רדיו',
          theme: ThemeData(
              fontFamily: 'Lato',
              iconTheme: const IconThemeData(color: Colors.white),
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
                  .copyWith(secondary: Colors.white)),
          home: const TabsController(),
          routes: {
            DetailPlayerScreen.routeName: (ctx) => const DetailPlayerScreen()
          },
        ),
      ),
    );
  }
}

Future<void> _initForegroundTask() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: androidNotificationOptions,
    iosNotificationOptions: iosNotificationOptions,
    foregroundTaskOptions: foregroundTaskOptions,
  );
}
