import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/database/data_classes.dart';
import '../lib/database/database_helper.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';
import '../lib/episode/description.dart';
import 'about_feed_load_test.dart';
import 'setting_screen_loadtest.dart';

void episodeScreenLoadTest(String _testDesc) =>
    testWidgets(_testDesc, (tester) async {
      await tester.pumpWidget(MyApp());
      final FeedState myFeedState = tester.state(find.byType(FeedWidget));
      expect(myFeedState.feedList.length == 0, true);

      int i = 0;
      while ((myFeedState.feedList.length == 0) && (i < 200)) {
        await tester.pumpAndSettle();
        i++;
      }

      expect(myFeedState.feedList.length > 0, true);
      int end = myFeedState.feedList.length;

      for (int i = 0; i < end; i++) {
        await tapInkWell(tester, i, myFeedState.feedList[i]);
      }
    });

Future<void> findEpisodeTileImage(WidgetTester tester,
    ScrollableEpisode _episode, Padding _episodeTile) async {
  Finder tileImageFinder = find.descendant(
    of: find.byWidget(_episodeTile),
    matching: find.byType(Image),
  );
  expect(tileImageFinder, findsOneWidget);
  Image tileImage = tileImageFinder.evaluate().single.widget as Image;
  String tileImageString = tileImage.image.toString();
  if (tileImageString.substring(0, 12) == "NetworkImage") {
    String shouldMatch = 'NetworkImage("${_episode.imageUrl}", scale: 1.0)';
    expect(tileImageString == shouldMatch, true);
  } else {
    String _sDirPath = await getSDir();
    String shouldMatch =
        'FileImage("${_sDirPath}/images/${_episode.imageFileName}", scale: 1.0)';
    expect(tileImageString == shouldMatch, true);
  }
}

Future<void> findAboutEpisodeImage(
    WidgetTester tester, ScrollableEpisode _episode) async {
  Finder episodeAboutImageFinder = find.byType(Image);
  expect(episodeAboutImageFinder, findsOneWidget);
  Image episodeAboutImage =
      episodeAboutImageFinder.evaluate().single.widget as Image;
  String episodeAboutImageString = episodeAboutImage.image.toString();
  if (episodeAboutImageString.substring(0, 12) == "NetworkImage") {
    String shouldMatch = 'NetworkImage("${_episode.imageUrl}", scale: 1.0)';
    expect(episodeAboutImageString == shouldMatch, true);
  } else {
    String _sDirPath = await getSDir();
    String shouldMatch =
        'FileImage("${_sDirPath}/images/${_episode.imageFileName}", scale: 1.0)';
    expect(episodeAboutImageString == shouldMatch, true);
  }
}

Future<void> findAboutEpisodeHTML(
    WidgetTester tester, ScrollableEpisode _episode) async {
  Finder episodeAboutHTMLFinder = find.byType(Html);
  expect(episodeAboutHTMLFinder, findsOneWidget);
  Html episodeAboutHTML = episodeAboutHTMLFinder.evaluate().single.widget as Html;
  expect(episodeAboutHTML.data == getHtml(_episode.desc), true);
}

Future<void> tapEpisodeInkWell(WidgetTester tester, ScrollableEpisode _episode,
    Padding _episodeTile) async {
  Finder episodeTileInkWellFinder = find.descendant(
    of: find.byWidget(_episodeTile),
    matching: find.byType(InkWell),
  );
  expect(episodeTileInkWellFinder, findsOneWidget);
  InkWell episodeTileInkWell =
      episodeTileInkWellFinder.evaluate().single.widget as InkWell;
  await (tester.tap(find.byWidget(episodeTileInkWell)));
  await tester.pumpAndSettle();
  await verifyAppBarTitle(tester, _episode.title);
  await findAboutEpisodeImage(tester, _episode);

  await clickBackButton(tester);
}

Future<void> findEpisodeTile(
    WidgetTester tester, int i, ScrollableEpisode _episode) async {
  await tester.ensureVisible(find.byKey(Key('padding_$i')));
  Finder tileFinder = find.byKey(Key('padding_$i'));
  expect(tileFinder, findsOneWidget);
  Padding episodeTile = tileFinder.evaluate().single.widget as Padding;
  Finder tileTextFinder = find.descendant(
    of: find.byWidget(episodeTile),
    matching: find.byType(Text),
  );
  expect(tileTextFinder, findsOneWidget);
  Text tileText = tileTextFinder.evaluate().single.widget as Text;
  expect(tileText.data == _episode.title, true);
  await findEpisodeTileImage(tester, _episode, episodeTile);
  await tapEpisodeInkWell(tester, _episode, episodeTile);
}

Future<void> getEpisodeList(WidgetTester tester, ScrollableFeed _feed) async {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<ScrollableEpisode> episodes =
      await dbHelper.getScrollableEpisodeList(_feed.id);
  expect(episodes.length > 0, true);
  int end = episodes.length;
  for (int i = 0; i < end; i++) {
    await tester.pumpAndSettle();
    await findEpisodeTile(tester, i, episodes[i]);
  }
}

Future<void> tapInkWell(
    WidgetTester tester, int i, ScrollableFeed _feed) async {
  Finder feedInkWellContainerFinder = find.byKey(Key('inkwell_$i'));
  expect(feedInkWellContainerFinder, findsOneWidget);
  Container feedInkWellContainer =
      feedInkWellContainerFinder.evaluate().single.widget as Container;
  Finder feedInkWellFinder = find.descendant(
    of: find.byWidget(feedInkWellContainer),
    matching: find.byType(InkWell),
  );
  expect(feedInkWellFinder, findsOneWidget);
  InkWell feedInkWell = feedInkWellFinder.evaluate().single.widget as InkWell;
  await (tester.tap(find.byWidget(feedInkWell)));
  await tester.pumpAndSettle();
  await verifyAppBarTitle(tester, _feed.title);
  await getEpisodeList(tester, _feed);

  await clickBackButton(tester);
}
