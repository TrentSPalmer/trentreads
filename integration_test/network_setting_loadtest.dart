import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trentreads/pref_utils.dart';

import '../lib/home/feeds.dart';
import '../lib/main.dart';
import 'about_feed_load_test.dart';
import 'setting_screen_loadtest.dart';
import 'storage_setting_loadtest.dart';

void networkSettingLoadTest(String _testDesc) =>
    testWidgets(_testDesc, (tester) async {
      await tester.pumpWidget(MyApp());
      final FeedState myFeedState = tester.state(find.byType(FeedWidget));
      expect(myFeedState.feedList.length == 0, true);
      int i = 0;
      while ((myFeedState.feedList.length == 0) && (i < 200)) {
        await tester.pumpAndSettle();
        i++;
      }
      await goToSettingsPage(tester);
      await goToNetworkSettingsPage(tester);
      await verifyAppBarTitle(tester, "Network Settings");
      await verifyHomeButton(tester);
      await goToSettingsPage(tester);
      await goToNetworkSettingsPage(tester);
      await verifyOKButton(tester, "Settings");
      await goToNetworkSettingsPage(tester);
      await verifyMobileNetworkSwitchTile(tester, true);
      await verifyMobileNetworkSwitchTile(tester, false);

      await clickBackButton(tester);
    });

Future<void> verifyMobileNetworkSwitchTile(
    WidgetTester tester, bool _isToggled) async {
  String myT = "Enable Automatic Downloads to Local ";
  myT += "Storage when connected to Mobile Network?";
  String mobileNetworkSwitchTileText = myT;
  Key finderKey = Key('switch_tile_for_$mobileNetworkSwitchTileText');
  Finder mobileNetworkSwitchTileFinder = find.byKey(finderKey);
  expect(mobileNetworkSwitchTileFinder, findsOneWidget);
  Padding mobileNetworkSwitchTile =
      mobileNetworkSwitchTileFinder.evaluate().single.widget as Padding;
  Finder mobileNetworkSwitchTileTextFinder = find.descendant(
    of: find.byWidget(mobileNetworkSwitchTile),
    matching: find.byType(Text),
  );
  expect(mobileNetworkSwitchTileTextFinder, findsOneWidget);
  Text foundMobileNetworkSwitchTileText =
      mobileNetworkSwitchTileTextFinder.evaluate().single.widget as Text;
  expect(foundMobileNetworkSwitchTileText.data == mobileNetworkSwitchTileText,
      true);
  Finder mobileNetworkSwitchFinder = find.descendant(
    of: find.byWidget(mobileNetworkSwitchTile),
    matching: find.byType(Switch),
  );
  expect(mobileNetworkSwitchFinder, findsOneWidget);
  Switch mobileNetworkSwitch =
      mobileNetworkSwitchFinder.evaluate().single.widget as Switch;
  expect(mobileNetworkSwitch.value, _isToggled);
  expect((await getMobileDownLoadOK()), _isToggled);
  await (tester.tap(find.byWidget(mobileNetworkSwitch)));
  await tester.pumpAndSettle();
}

Future<void> goToNetworkSettingsPage(WidgetTester tester) async {
  Finder networkNavTileFinder =
      find.byKey(Key('nav_tile_for_${settingNavTilesStringList[2]}'));
  expect(networkNavTileFinder, findsOneWidget);
  Row networkNavTile = networkNavTileFinder.evaluate().single.widget as Row;
  Finder inkWellFinder = find.descendant(
    of: find.byWidget(networkNavTile),
    matching: find.byType(InkWell),
  );
  expect(inkWellFinder, findsOneWidget);
  InkWell navTileInkWell = inkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(navTileInkWell));
  await tester.pumpAndSettle();
}
