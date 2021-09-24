import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';

List<NetworkImage> feedsNetworkImages = [
  NetworkImage(
    "https://static.trentpalmer.org/audio/images/mark_twain_by_af_bradley.jpg",
    scale: 1.0,
  ),
  NetworkImage(
    "https://static.trentpalmer.org/audio/images/464px-caesar_campaigns_gaul-ensvg.png",
    scale: 1.0,
  ),
  NetworkImage(
    "https://static.trentpalmer.org/audio/images/378px-pompeius_kopenhagen.jpg",
    scale: 1.0,
  ),
  NetworkImage(
    "https://static.trentpalmer.org/audio/images/302px-plutarchs_lives.jpg",
    scale: 1.0,
  ),
];

void homeScreenLoadTest(String _testDesc) =>
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
      List<String> listTitles = [];

      for (int i = 0; i < end; i++) {
        Finder itemTitleText = find.byKey(Key('feed_title_$i'));
        Text text = itemTitleText.evaluate().single.widget as Text;
        listTitles.add(text.data ?? '');
        Finder itemImageFinder = find.byKey(Key('image_${i}'));
        Widget itemImageWidget =
            itemImageFinder.evaluate().single.widget as Widget;
        int j = 0;
        while ((itemImageWidget.runtimeType != Image) && (j < 200)) {
          await tester.pumpAndSettle();
          j++;
          itemImageWidget = itemImageFinder.evaluate().single.widget as Widget;
        }
        Image itemImage = itemImageFinder.evaluate().single.widget as Image;
        expect(itemImage.image == feedsNetworkImages[i], true);
      }

      expect(listTitles.contains("Short Stories Mark Twain"), true);
      expect(
          listTitles.contains("Caesar's De Bello Gallico & Other Commentaries"),
          true);
      expect(listTitles.contains("Caesar-Pompey Civil War"), true);
      expect(listTitles.contains("Plutarch's Lives Volume 1 of 4"), true);
    });
