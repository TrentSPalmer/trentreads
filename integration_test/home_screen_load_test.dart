import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/home/home.dart';
import '../lib/main.dart';


void homeScreenLoadTest(String _testDesc) =>
    testWidgets(_testDesc, (tester) async {
      await tester.pumpWidget(MyApp());
      final MyHomePageState myHomePageState =
      tester.state(find.byType(MyHomePage));
      expect(myHomePageState.feedList.length == 0, true);

      int i = 0;
      while ((myHomePageState.feedList.length == 0) && (i < 10)) {
        await tester.pumpAndSettle();
        i++;
      }

      expect(myHomePageState.feedList.length > 0, true);
      int end = myHomePageState.feedList.length;
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
