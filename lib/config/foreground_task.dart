import 'package:flutter_foreground_task/flutter_foreground_task.dart';

final androidNotificationOptions = AndroidNotificationOptions(
  channelId: 'israel_radio_timer',
  channelName: "רדיו ישראל",
  channelDescription: "שעון רדיו מעורר רץ ברקע",
  channelImportance: NotificationChannelImportance.LOW,
  priority: NotificationPriority.LOW,
  iconData: const NotificationIconData(
    resType: ResourceType.mipmap,
    resPrefix: ResourcePrefix.ic,
    name: 'background_icon',
  ),
);

const iosNotificationOptions = IOSNotificationOptions(
  showNotification: true,
  playSound: false,
);

const foregroundTaskOptions = ForegroundTaskOptions(
  interval: 5000,
  autoRunOnBoot: true,
  allowWifiLock: false,
);
