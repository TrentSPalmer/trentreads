import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trentreads/pref_utils.dart';

import '../lib/database/database_helper.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';
import 'about_feed_load_test.dart';
import 'setting_screen_loadtest.dart';
import 'storage_setting_loadtest.dart';

void downloadSettingLoadTest(String _testDesc) =>
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
      await goToDownLoadSettingsPage(tester);
      await verifyAppBarTitle(tester, "Global Download Settings");
      await verifyHomeButton(tester);
      await goToSettingsPage(tester);
      await goToDownLoadSettingsPage(tester);
      await verifyOKButton(tester, "Settings");
      await goToDownLoadSettingsPage(tester);
      await verifyDownLoadSettingsInfoTile(tester);
      await verifyGlobalDownLoadDefaultSettingsSwitchTile(tester, true);
      await verifyGlobalDownLoadDefaultSettingsSwitchTile(tester, false);
      await verifyGlobalDownLoadDefaultSettingForAllFeedsSpecificallySwitchTile(
          tester, true, myFeedState.feedList.length);
      await verifyGlobalDownLoadDefaultSettingForAllFeedsSpecificallySwitchTile(
          tester, false, myFeedState.feedList.length);

      await clickBackButton(tester);
    });

Future<void>
    verifyGlobalDownLoadDefaultSettingForAllFeedsSpecificallySwitchTile(
        WidgetTester tester, bool _isToggled, int _numFeeds) async {
  String myText = "Enable Downloads to Local Storage";
  myText += " For All Feeds Specifically? ";
  int _enabledFeeds = (_isToggled) ? _numFeeds : 0;
  myText += "($_enabledFeeds of $_numFeeds feeds are currently enabled)";
  String downLoadDefaultInfoForAllFeedsSpecificallyText = myText;
  Key finderKey =
      Key('switch_tile_for_$downLoadDefaultInfoForAllFeedsSpecificallyText');
  Finder downloadDefaultSwitchForAllFeedSpecificallyTileFinder =
      find.byKey(finderKey);
  expect(downloadDefaultSwitchForAllFeedSpecificallyTileFinder, findsOneWidget);
  Padding downloadDefaultSwitchForAllFeedsSpecificallyTile =
      downloadDefaultSwitchForAllFeedSpecificallyTileFinder
          .evaluate()
          .single
          .widget as Padding;
  Finder downloadDefaultSwitchForAllFeedsSpecificallyTileTextFinder =
      find.descendant(
    of: find.byWidget(downloadDefaultSwitchForAllFeedsSpecificallyTile),
    matching: find.byType(Text),
  );
  expect(downloadDefaultSwitchForAllFeedsSpecificallyTileTextFinder,
      findsOneWidget);
  Text downloadDefaultSwitchForAllFeedsSpecificallyTileText =
      downloadDefaultSwitchForAllFeedsSpecificallyTileTextFinder
          .evaluate()
          .single
          .widget as Text;
  expect(
      downloadDefaultSwitchForAllFeedsSpecificallyTileText.data ==
          downLoadDefaultInfoForAllFeedsSpecificallyText,
      true);
  Finder downloadDefaultSwitchForAllFeedsSpecificallyFinder = find.descendant(
    of: find.byWidget(downloadDefaultSwitchForAllFeedsSpecificallyTile),
    matching: find.byType(Switch),
  );
  expect(downloadDefaultSwitchForAllFeedsSpecificallyFinder, findsOneWidget);
  Switch downloadDefaultSwitchForAllFeedsSpecifically =
      downloadDefaultSwitchForAllFeedsSpecificallyFinder
          .evaluate()
          .single
          .widget as Switch;
  expect(downloadDefaultSwitchForAllFeedsSpecifically.value, _isToggled);
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  expect((await dbHelper.downLoadEnabledForAllFeeds()), _isToggled);
  await tester.tap(find.byWidget(downloadDefaultSwitchForAllFeedsSpecifically));
  await tester.pumpAndSettle();
}

Future<void> verifyGlobalDownLoadDefaultSettingsSwitchTile(
    WidgetTester tester, bool _isToggled) async {
  String downLoadDefaultInfoText =
      "Enable Downloads to Local Storage by Default?";
  Key finderKey = Key('switch_tile_for_$downLoadDefaultInfoText');
  Finder downloadDefaultSwitchTileFinder = find.byKey(finderKey);
  expect(downloadDefaultSwitchTileFinder, findsOneWidget);
  Padding downloadDefaultSwitchTile =
      downloadDefaultSwitchTileFinder.evaluate().single.widget as Padding;
  Finder downloadDefaultSwitchTileTextFinder = find.descendant(
    of: find.byWidget(downloadDefaultSwitchTile),
    matching: find.byType(Text),
  );
  expect(downloadDefaultSwitchTileTextFinder, findsOneWidget);
  Text downloadDefaultSwitchTileText =
      downloadDefaultSwitchTileTextFinder.evaluate().single.widget as Text;
  expect(downloadDefaultSwitchTileText.data == downLoadDefaultInfoText, true);
  Finder downloadDefaultSwitchFinder = find.descendant(
    of: find.byWidget(downloadDefaultSwitchTile),
    matching: find.byType(Switch),
  );
  expect(downloadDefaultSwitchFinder, findsOneWidget);
  Switch downloadDefaultSwitch =
      downloadDefaultSwitchFinder.evaluate().single.widget as Switch;
  expect(downloadDefaultSwitch.value, _isToggled);
  expect((await globalGetShouldDownLoadDefault()), _isToggled);
  await tester.tap(find.byWidget(downloadDefaultSwitch));
  await tester.pumpAndSettle();
}

Future<void> verifyDownLoadSettingsInfoTile(WidgetTester tester) async {
  String infoTileText = "0 episodes are downloaded to local storage.";
  Key finderKey = Key('info_tile_for_$infoTileText');
  Finder downloadSettingsInfoTileFinder = find.byKey(finderKey);
  expect(downloadSettingsInfoTileFinder, findsOneWidget);
  Row downloadSettingsInfoTile =
      downloadSettingsInfoTileFinder.evaluate().single.widget as Row;
  Finder downloadSettingsInfoTextFinder = find.descendant(
    of: find.byWidget(downloadSettingsInfoTile),
    matching: find.byType(Text),
  );
  expect(downloadSettingsInfoTextFinder, findsOneWidget);
  Text downloadSettingsInfoText =
      downloadSettingsInfoTextFinder.evaluate().single.widget as Text;
  expect(downloadSettingsInfoText.data == infoTileText, true);
}

Future<void> goToDownLoadSettingsPage(WidgetTester tester) async {
  Finder storageNavTileFinder =
      find.byKey(Key('nav_tile_for_${settingNavTilesStringList[1]}'));
  expect(storageNavTileFinder, findsOneWidget);
  Row storageNavTile = storageNavTileFinder.evaluate().single.widget as Row;
  Finder inkWellFinder = find.descendant(
    of: find.byWidget(storageNavTile),
    matching: find.byType(InkWell),
  );
  expect(inkWellFinder, findsOneWidget);
  InkWell navTileInkWell = inkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(navTileInkWell));
  await tester.pumpAndSettle();
}
