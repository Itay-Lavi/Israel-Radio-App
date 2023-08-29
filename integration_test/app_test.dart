// Example test in app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radio_timer_app/main.dart' as app;
import 'package:radio_timer_app/widgets/alertdialogs/scheduler/scheduler_dialog.dart';
import 'package:radio_timer_app/widgets/alertdialogs/timer_dialog.dart';
import 'package:radio_timer_app/widgets/channels/grid_item.dart';
import 'package:radio_timer_app/widgets/channels/list_item.dart';
import 'package:radio_timer_app/widgets/player/channels_bottom_player.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('EndToEnd', () {
    testWidgets('Choose station and play radio test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final radioItems = find.byType(ChannelsListItem);
      expect(radioItems, findsWidgets);

      await tester.tap(radioItems.at(4)); //galgaltz

      final pauseBtn = find.byIcon(Icons.pause_circle);
      await pumpUntilFound(tester, pauseBtn);

      expect(pauseBtn, findsOneWidget);
      await tester.tap(pauseBtn);
    });

    testWidgets('Favorite test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      Future<void> switchFavoriteTab() async {
        final favoriteTab = find.text('מעודפים');
        await tester.tap(favoriteTab);
        await tester.pumpAndSettle();
      }

      Future<void> switchAllTab() async {
        final allTab = find.text('כל התחנות');
        await tester.tap(allTab);
        await tester.pumpAndSettle();
      }

      final favoriteBorderBtns = find.byIcon(Icons.favorite_border);
      expect(favoriteBorderBtns, findsWidgets);

      await tester.tap(favoriteBorderBtns.first);
      await tester.pumpAndSettle();

      await switchFavoriteTab();

      Finder radioItems = find.byType(ChannelsListItem);
      expect(radioItems, findsAtLeastNWidgets(1));

      await switchAllTab();

      final favoriteBtns = find.byIcon(Icons.favorite);
      expect(favoriteBtns, findsWidgets);

      await tester.tap(favoriteBtns.first);
      await tester.pumpAndSettle();

      await switchFavoriteTab();

      radioItems = find.byType(ChannelsListItem);
      expect(radioItems, findsNothing);
    });

    testWidgets('Viewtype test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final gridBtn = find.byIcon(Icons.grid_on);
      expect(gridBtn, findsOneWidget);
      await tester.tap(gridBtn);
      await tester.pumpAndSettle();

      final gridItems = find.byType(ChannelsGridItem);
      expect(gridItems, findsWidgets);

      final tileBtn = find.byIcon(Icons.list_alt);
      expect(tileBtn, findsOneWidget);
      await tester.tap(tileBtn);
      await tester.pumpAndSettle();

      final tileItems = find.byType(ChannelsListItem);
      expect(tileItems, findsWidgets);
    });

    testWidgets('Test player detail screen and alert dialog', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final channelsBottomPlayer = find.byType(ChannelsBottomPlayer);
      expect(channelsBottomPlayer, findsOneWidget);

      await tester.tap(channelsBottomPlayer);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      Future<void> alertDialogTest(
          {required IconData icon, required Type dialogWidget}) async {
        final iconBtn = find.byIcon(icon);
        expect(iconBtn, findsOneWidget);

        await tester.tap(iconBtn);
        await tester.pumpAndSettle();

        final dialog = find.byType(dialogWidget);
        expect(dialog, findsOneWidget);

        await tester.tap(find.text('סגור'));
        await tester.pumpAndSettle();
      }

      await alertDialogTest(
          icon: Icons.bedtime_outlined, dialogWidget: TimerDialog);
      await alertDialogTest(icon: Icons.alarm, dialogWidget: ScheduleDialog);

      final goBackBtn = find.byIcon(Icons.arrow_downward);
      expect(goBackBtn, findsOneWidget);

      await tester.tap(goBackBtn);
      await tester.pumpAndSettle();
    });
  });
}
