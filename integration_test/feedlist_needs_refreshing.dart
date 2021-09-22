import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/home/feed_downloaders.dart';
import '../lib/home/home.dart';
import '../lib/main.dart';
import '../lib/pref_utils.dart';
import 'app_test.dart';


void feedListNeedsRefreshing(String _testDesc) =>
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
      expect((await lastFeedsUpdateExpired()), false);
      expect((await fetchFeeds()), false);
      expect((await lastFeedsUpdateExpired()), false);
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      int _lastUpdate = await _prefs.getInt(feedsLastUpdatedAt) ?? 0;
      expect((_lastUpdate > 0), true);

      // make it look like the feedsLastUpdateAt is now expired
      await _prefs.setInt(feedsLastUpdatedAt, 0);
      expect((await lastFeedsUpdateExpired()), true);
      expect((await fetchFeeds()), false);
    });
