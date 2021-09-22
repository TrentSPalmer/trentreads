import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';


void homeScreenLoadTest(String _testDesc) =>
    testWidgets(_testDesc, (tester) async {
      await tester.pumpWidget(MyApp());
      final FeedState myFeedState =
      tester.state(find.byType(FeedWidget));
      expect(myFeedState.feedList.length == 0, true);

      int i = 0;
      while ((myFeedState.feedList.length == 0) && (i < 200)) {
        await tester.pumpAndSettle();
        i++;
      }

      expect(myFeedState.feedList.length > 0, true);
      int end = myFeedState.feedList.length;
      List<String> listTitles = [];

      for (int i = 0; i < end; i++) {
        Finder itemTitleText = find.byKey(Key('feed_title_$i'));
        Text text = itemTitleText.evaluate().single.widget as Text;
        listTitles.add(text.data ?? '');
      }

      expect(listTitles.contains("Short Stories Mark Twain"), true);
      expect(
          listTitles.contains("Caesar's De Bello Gallico & Other Commentaries"),
          true);
      expect(listTitles.contains("Caesar-Pompey Civil War"), true);
    });
