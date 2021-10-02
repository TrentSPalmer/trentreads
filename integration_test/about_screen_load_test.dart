import 'package:flutter_test/flutter_test.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';

import 'setting_screen_loadtest.dart';

void aboutScreenLoadTest(String _testDesc) =>
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
    });