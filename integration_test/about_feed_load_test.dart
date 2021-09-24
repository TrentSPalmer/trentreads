import 'package:flutter/material.dart';
import '../lib/main.dart';
import '../lib/home/feeds.dart';
import 'package:flutter_test/flutter_test.dart';

void aboutFeedsLoadTest(String _testDesc) =>
    testWidgets(_testDesc, (tester) async {
      await tester.pumpWidget(MyApp());
      final FeedState myFeedState = tester.state(find.byType(FeedWidget));
      expect(myFeedState.feedList.length == 0, true);

      int i = 0;
      while ((myFeedState.feedList.length == 0) && (i < 200)) {
        await tester.pumpAndSettle();
        i++;
      }

      Finder inkWell0Finder = find.byKey(Key('inkwell_0'));
      expect(inkWell0Finder, findsOneWidget);
      await tester.tap(find.byKey(Key('inkwell_0')));
      await tester.pumpAndSettle();
      Finder feed0DescTitleFinder = find.byKey(Key('feed_description_title'));
      expect(feed0DescTitleFinder, findsOneWidget);
      Text feed0DescTitle = feed0DescTitleFinder.evaluate().single.widget as Text;
      expect(feed0DescTitle.data == 'Short Stories By Mark Twain', true);
    });