import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import '../lib/home/feeds.dart';
import 'about_feed_load_test.dart';

void settingScreenLoadTest(String _testDesc) =>
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
      await verifyAppBarTitle(tester, "Settings");
      await verifySettingsColumn(tester,
          numTiles: settingNavTilesStringList.length);
      await verifyNavTiles(tester, settingNavTilesStringList);

      await clickBackButton(tester);
    });

Future<void> verifyNavTiles(
    WidgetTester tester, List<String> navTilesStringList) async {
  int end = navTilesStringList.length;
  for (int j = 0; j < end; j++) {
    Finder navTileFinder =
        find.byKey(Key('nav_tile_for_${navTilesStringList[j]}'));
    expect(navTileFinder, findsOneWidget);
    Row jNavTile = navTileFinder.evaluate().single.widget as Row;
    Finder jNavTileTextFinder = find.descendant(
      of: find.byWidget(jNavTile),
      matching: find.byType(Text),
    );
    expect(jNavTileTextFinder, findsOneWidget);
    Text jNavTileText = jNavTileTextFinder.evaluate().single.widget as Text;
    expect(jNavTileText.data == navTilesStringList[j], true);
  }
}

Future<void> verifySettingsColumn(WidgetTester tester,
    {int numTiles = 0}) async {
  Finder columnFinder = find.byType(Column);
  expect(columnFinder, findsOneWidget);
  Column settingsPageColumn = columnFinder.evaluate().single.widget as Column;
  Finder columnChildrenFinder = find.descendant(
    of: find.byWidget(settingsPageColumn),
    matching: find.byType(Row),
  );
  expect(columnChildrenFinder, findsNWidgets(numTiles));
}

Future<void> verifyAppBarTitle(WidgetTester tester, String _title) async {
  Finder appBarFinder = find.byType(AppBar);
  expect(appBarFinder, findsOneWidget);
  AppBar settingsAppBar = appBarFinder.evaluate().single.widget as AppBar;
  Finder settingsAppBarTitleTextFinder = find.descendant(
    of: find.byWidget(settingsAppBar),
    matching: find.byType(Text),
  );
  expect(settingsAppBarTitleTextFinder, findsOneWidget);
  Text settingsAppBarTitleText =
      settingsAppBarTitleTextFinder.evaluate().single.widget as Text;
  expect(settingsAppBarTitleText.data == _title, true);
}

Future<void> goToSettingsPage(WidgetTester tester) async {
  Finder settingsIconFinder = find.byKey(Key('feed_page_settings_icon'));
  expect(settingsIconFinder, findsOneWidget);
  await tester.tap(find.byKey(Key('feed_page_settings_icon')));
  await tester.pumpAndSettle();
}

List<String> settingNavTilesStringList = [
  'Select Storage Device',
  'Download Settings',
  'Network Settings',
  'About TrentReads',
];
