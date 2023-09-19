import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './widgets/tabs_controller.dart';
import '../screens/detail_player_screen.dart';
import '../providers/ui_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/day_schedule.dart';
import '../providers/channels_provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterAlarmBackgroundTrigger.initialize();
  await dotenv.load(fileName: "config.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ChannelsProvider()),
        ChangeNotifierProvider(create: (ctx) => DaysSchedule()),
        ChangeNotifierProvider(create: (ctx) => TimerProvider()),
        ChangeNotifierProvider(create: (ctx) => UiProvider()),
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
    );
  }
}
