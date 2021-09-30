import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/home/feeds.dart';
import '../lib/main.dart';

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
      int end = myFeedState.feedList.length;
      for (int i = 0; i < end; i++) {
        await findAndTapAboutFeedInkWell(i, tester);
        await testFeedDesc(i, tester, myFeedState.feedList[i].desc);
        await testFeedImageDesc(i, tester, myFeedState.feedList[i].imageDesc);
        await clickBackButton(tester);
      }
    });

Future<void> clickBackButton(WidgetTester tester) async {
  Finder backButtonFinder = find.byType(BackButton);
  expect(backButtonFinder, findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> testFeedImageDesc(
    int i, WidgetTester tester, String _feedImageDesc) async {
  Finder feediImageDescFinder = find.byKey(Key('feed_image_description'));
  expect(feediImageDescFinder, findsOneWidget);
  Html feediImageDesc = feediImageDescFinder.evaluate().single.widget as Html;
  expect(feediImageDesc.data == _feedImageDesc, true);
}

Future<void> testFeedDesc(int i, WidgetTester tester, String _feedDesc) async {
  Finder feediDescFinder = find.byKey(Key('feed_description'));
  expect(feediDescFinder, findsOneWidget);
  Text feediDesc = feediDescFinder.evaluate().single.widget as Text;
  expect(feediDesc.data == _feedDesc, true);
}

Future<void> findAndTapAboutFeedInkWell(int i, WidgetTester tester) async {
  Finder inkWelliFinder = find.byKey(Key('inkwell_$i'));
  expect(inkWelliFinder, findsOneWidget);
  await tester.tap(find.byKey(Key('inkwell_$i')));
  await tester.pumpAndSettle();
}
