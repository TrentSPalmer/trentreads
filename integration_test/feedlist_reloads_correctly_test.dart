import 'package:flutter_test/flutter_test.dart';
import '../lib/database/data_classes.dart';
import '../lib/home/feeds.dart';

import '../lib/database/database_helper.dart';
import '../lib/main.dart';


void feedListReloadsCorrectly(String _testDesc) =>
    testWidgets(_testDesc, (tester) async {
      await tester.pumpWidget(MyApp());
      final FeedState myFeedState =
          tester.state(find.byType(FeedWidget));
      expect(myFeedState.feedList.length == 0, true);

      int i = 0;
      while ((myFeedState.feedList.length == 0) && (i < 10)) {
        await tester.pumpAndSettle();
        i++;
      }
      int _currentFeedListLength = myFeedState.feedList.length;
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      String _deletedFeedTitle = await dbHelper.deleteFeed(1);
      await myFeedState.reloadFeeds();
      await tester.pumpAndSettle();
      expect((myFeedState.feedList.length == (_currentFeedListLength - 1)),
          true);
      List<String> _listTitles = [];
      myFeedState.feedList.forEach((ScrollableFeed x) {
        _listTitles.add(x.title);
      });
      print("$_deletedFeedTitle was deleted.");
      expect((!_listTitles.contains(_deletedFeedTitle)), true);
    });
