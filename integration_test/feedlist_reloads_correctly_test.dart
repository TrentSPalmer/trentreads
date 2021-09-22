import 'package:flutter_test/flutter_test.dart';

import '../lib/database/data_classes.dart';
import '../lib/database/database_helper.dart';
import '../lib/home/home.dart';
import '../lib/main.dart';


void feedListReloadsCorrectly(String _testDesc) =>
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
      int _currentFeedListLength = myHomePageState.feedList.length;
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      String _deletedFeedTitle = await dbHelper.deleteFeed(1);
      await myHomePageState.reloadFeeds();
      await tester.pumpAndSettle();
      expect((myHomePageState.feedList.length == (_currentFeedListLength - 1)),
          true);
      List<String> _listTitles = [];
      myHomePageState.feedList.forEach((ScrollableFeed x) {
        _listTitles.add(x.title);
      });
      print("$_deletedFeedTitle was deleted.");
      expect((!_listTitles.contains(_deletedFeedTitle)), true);
    });
