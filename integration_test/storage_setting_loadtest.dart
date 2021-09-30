import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage_info/storage_info.dart';
import 'package:trentreads/download/utils.dart';

import '../lib/home/feeds.dart';
import '../lib/main.dart';
import 'about_feed_load_test.dart';
import 'setting_screen_loadtest.dart';

void storageSettingLoadTest(String _testDesc) =>
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
      await goToStorageSettingsPage(tester);
      await verifyAppBarTitle(tester, "Storage");
      await verifyHomeButton(tester);
      await goToSettingsPage(tester);
      await goToStorageSettingsPage(tester);
      await verifyOKButton(tester, "Settings");
      await goToStorageSettingsPage(tester);
      await verifyCorrectStorageDeviceSelected(
          tester, (await verifyMultipleStorageDirs(tester)));

      await clickBackButton(tester);
    });

Future<void> verifyCorrectStorageDeviceSelected(
    WidgetTester tester, bool multipleStorageDevices) async {
  if (multipleStorageDevices) {
    double _exFree = await StorageInfo.getExternalStorageFreeSpaceInGB;
    double _inFree = await StorageInfo.getStorageFreeSpaceInGB;
    if (_exFree > _inFree) {
      Finder externalStorageDeviceRadioListTileFinder =
          find.byKey(Key('external_storage_device_radio_list_tile'));
      RadioListTile externalRadioListTile =
          externalStorageDeviceRadioListTileFinder.evaluate().single.widget
              as RadioListTile;
      expect(externalRadioListTile.value.toString() == "StorageDev.external",
          true);
    } else {
      await verifyInternalStorageDeviceSelected(tester);
    }
  } else {
    await verifyInternalStorageDeviceSelected(tester);
  }
}

Future<void> verifyInternalStorageDeviceSelected(WidgetTester tester) async {
  Finder innerStorageDeviceRadioListTileFinder =
      find.byKey(Key('internal_storage_device_radio_list_tile'));
  RadioListTile internalRadioListTile = innerStorageDeviceRadioListTileFinder
      .evaluate()
      .single
      .widget as RadioListTile;
  expect(internalRadioListTile.value.toString() == "StorageDev.internal", true);
}

Future<bool> verifyMultipleStorageDirs(WidgetTester tester) async {
  Finder innerStorageDeviceRadioListTileFinder =
      find.byKey(Key('internal_storage_device_radio_list_tile'));
  expect(innerStorageDeviceRadioListTileFinder, findsOneWidget);
  Finder externalStorageDeviceRadioListTileFinder =
      find.byKey(Key('external_storage_device_radio_list_tile'));
  if (await multipleStorageDirs()) {
    expect(externalStorageDeviceRadioListTileFinder, findsOneWidget);
    return true;
  } else {
    expect(externalStorageDeviceRadioListTileFinder, findsNothing);
    return false;
  }
}

Future<void> verifyOKButton(
    WidgetTester tester, String goBackAppBarTitleString) async {
  Finder okButtonInkWellFinder = find.byKey(Key('ok_button_ink_well'));
  expect(okButtonInkWellFinder, findsOneWidget);
  InkWell okButtonInkWell =
      okButtonInkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(okButtonInkWell));
  await tester.pumpAndSettle();
  await verifyAppBarTitle(tester, goBackAppBarTitleString);
}

Future<void> verifyHomeButton(WidgetTester tester) async {
  Finder homeButtonInkWellFinder = find.byKey(Key('home_button_ink_well'));
  expect(homeButtonInkWellFinder, findsOneWidget);
  InkWell homeButtonInkWell =
      homeButtonInkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(homeButtonInkWell));
  await tester.pumpAndSettle();
  await verifyAppBarTitle(tester, "Feeds");
}

Future<void> goToStorageSettingsPage(WidgetTester tester) async {
  Finder storageNavTileFinder =
      find.byKey(Key('nav_tile_for_${settingNavTilesStringList[0]}'));
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
