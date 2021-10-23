import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/about/about_html.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';
import 'about_feed_load_test.dart';
import 'setting_screen_loadtest.dart';
import 'storage_setting_loadtest.dart';

void aboutScreenLoadTest(String _testDesc) =>
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
      await goToAboutSettingsPage(tester);
      await verifyAppBarTitle(tester, "About TrentReads");
      await verifyHomeButton(tester);
      await goToSettingsPage(tester);
      await goToAboutSettingsPage(tester);
      await verifyOKButton(tester, "Settings");
      await goToAboutSettingsPage(tester);
      await goToAboutTrentReadsPage(tester);
      await verifyAppBarTitle(tester, "About TrentReads");
      await findSingleChildScrollViewAndHtml(tester);
      await findShowLicenseTile(tester);
      await testShowLicense(tester);
      await findOtherLicenseTile(tester);
      await testShowOtherLicense(tester);
      await otherLicenseLoadTest(tester);

      await clickBackButton(tester);
    });

Future<void> otherLicenseLoadTest(WidgetTester tester) async {
  await verifyAppBarTitle(tester, "Licenses");
  await clickBackButton(tester);
}

Future<void> testShowOtherLicense(WidgetTester tester) async {
  Finder showOtherLicensesTileFinder =
      find.byKey(Key('func_tile_for_Other Licenses'));
  Padding showOtherLicensesTile =
      showOtherLicensesTileFinder.evaluate().single.widget as Padding;
  Finder showOtherLicensesTileInkWellFinder = find.descendant(
    of: find.byWidget(showOtherLicensesTile),
    matching: find.byType(InkWell),
  );
  expect(showOtherLicensesTileInkWellFinder, findsOneWidget);
  InkWell showOtherLicensesTileInkWell =
      showOtherLicensesTileInkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(showOtherLicensesTileInkWell));
  await tester.pumpAndSettle();
}

Future<void> findOtherLicenseTile(WidgetTester tester) async {
  Finder showOtherLicensesTileFinder =
      find.byKey(Key('func_tile_for_Other Licenses'));
  expect(showOtherLicensesTileFinder, findsOneWidget);
  Padding showOtherLicensesTile =
      showOtherLicensesTileFinder.evaluate().single.widget as Padding;
  Finder showOtherLicensesTileTextFinder = find.descendant(
    of: find.byWidget(showOtherLicensesTile),
    matching: find.byType(Text),
  );
  expect(showOtherLicensesTileTextFinder, findsOneWidget);
  Text showOtherLicensesTileText =
      showOtherLicensesTileTextFinder.evaluate().single.widget as Text;
  expect(showOtherLicensesTileText.data == "Other Licenses", true);
}

Future<void> testShowLicense(WidgetTester tester) async {
  Finder showLicenseTileFinder = find.byKey(Key('func_tile_for_License'));
  Padding showLicenseTile =
      showLicenseTileFinder.evaluate().single.widget as Padding;
  Finder showLicenseTileInkWellFinder = find.descendant(
    of: find.byWidget(showLicenseTile),
    matching: find.byType(InkWell),
  );
  expect(showLicenseTileInkWellFinder, findsOneWidget);
  // It's not possible to test this
  // InkWell showLicenseTileInkWell =
  //     showLicenseTileInkWellFinder.evaluate().single.widget as InkWell;
  // await tester.tap(find.byWidget(showLicenseTileInkWell));
  // await tester.pumpAndSettle();
}

Future<void> findShowLicenseTile(WidgetTester tester) async {
  Finder showLicenseTileFinder = find.byKey(Key('func_tile_for_License'));
  expect(showLicenseTileFinder, findsOneWidget);
  Padding showLicenseTile =
      showLicenseTileFinder.evaluate().single.widget as Padding;
  Finder showLicenseTileTextFinder = find.descendant(
    of: find.byWidget(showLicenseTile),
    matching: find.byType(Text),
  );
  expect(showLicenseTileTextFinder, findsOneWidget);
  Text showLicenseTileText =
      showLicenseTileTextFinder.evaluate().single.widget as Text;
  expect(showLicenseTileText.data == "License", true);
}

Future<void> findSingleChildScrollViewAndHtml(WidgetTester tester) async {
  Finder singleChildScrollViewFinder = find.byType(SingleChildScrollView);
  expect(singleChildScrollViewFinder, findsOneWidget);
  Finder htmlFinder = find.byType(Html);
  expect(htmlFinder, findsOneWidget);
  Html myAboutHtml = htmlFinder.evaluate().single.widget as Html;
  expect(myAboutHtml.data == aboutTrentReads.data, true);
  await clickBackButton(tester);
}

Future<void> goToAboutTrentReadsPage(WidgetTester tester) async {
  Finder aboutNavTileFinder =
      find.byKey(Key('nav_tile_for_${settingNavTilesStringList[3]}'));
  expect(aboutNavTileFinder, findsOneWidget);
  Row aboutNavTile = aboutNavTileFinder.evaluate().single.widget as Row;
  Finder inkWellFinder = find.descendant(
    of: find.byWidget(aboutNavTile),
    matching: find.byType(InkWell),
  );
  expect(inkWellFinder, findsOneWidget);
  InkWell navTileInkWell = inkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(navTileInkWell));
  await tester.pumpAndSettle();
}

Future<void> goToAboutSettingsPage(WidgetTester tester) async {
  Finder aboutNavTileFinder =
      find.byKey(Key('nav_tile_for_${settingNavTilesStringList[3]}'));
  expect(aboutNavTileFinder, findsOneWidget);
  Row aboutNavTile = aboutNavTileFinder.evaluate().single.widget as Row;
  Finder inkWellFinder = find.descendant(
    of: find.byWidget(aboutNavTile),
    matching: find.byType(InkWell),
  );
  expect(inkWellFinder, findsOneWidget);
  InkWell navTileInkWell = inkWellFinder.evaluate().single.widget as InkWell;
  await tester.tap(find.byWidget(navTileInkWell));
  await tester.pumpAndSettle();
}
