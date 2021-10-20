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

      await clickBackButton(tester);
    });

Future<void> findShowLicenseTile(WidgetTester tester) async {}

Future<void> findSingleChildScrollViewAndHtml(WidgetTester tester) async {
  Finder singleChildScrollViewFinder = find.byType(SingleChildScrollView);
  expect(singleChildScrollViewFinder, findsOneWidget);
  Finder htmlFinder = find.byType(Html);
  expect(htmlFinder, findsOneWidget);
  Html myAboutHtml = htmlFinder.evaluate().single.widget as Html;
  expect(myAboutHtml.data == aboutTrentReads.data, true);
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
