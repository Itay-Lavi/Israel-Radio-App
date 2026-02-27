import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './widgets/tabs_controller.dart';
import '../screens/detail_player_screen.dart';
import '../providers/ui_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/day_schedule.dart';
import '../providers/channels_provider.dart';
import 'services/audio_player_handler.dart';

late final RadioAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.itay.israel_radio.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationIcon: 'mipmap/launcher_icon',
      androidStopForegroundOnPause: false,
    ),
  );

  await dotenv.load(fileName: "config.env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) {
          final prov = ChannelsProvider();
          prov.setHandler(audioHandler);
          return prov;
        }),
        ChangeNotifierProvider(create: (ctx) => DaysSchedule()),
        ChangeNotifierProvider(create: (ctx) => TimerProvider()),
        ChangeNotifierProvider(create: (ctx) => UiProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'שעון רדיו',
        theme: ThemeData(
            useMaterial3: false,
            fontFamily: 'Lato',
            iconTheme: const IconThemeData(color: Colors.white),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
                .copyWith(secondary: Colors.white),
            scaffoldBackgroundColor: Colors.black),
        home: const TabsController(),
        routes: {
          DetailPlayerScreen.routeName: (ctx) => const DetailPlayerScreen()
        },
      ),
    );
  }
}
