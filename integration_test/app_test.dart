import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'about_feed_load_test.dart';
import 'feedlist_needs_refreshing.dart';
import 'feedlist_reloads_correctly_test.dart';
import 'home_screen_load_test.dart';

final String feedsLastUpdatedAt = 'feedsLastUpdatedAt';

void main() {
  group('Home Screen Load Tests', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;

    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

    homeScreenLoadTest('HomeScreen Load Test');
    feedListNeedsRefreshing('FeedList Needs Refreshing Test');
    aboutFeedsLoadTest("About Feeds Load Test");
    feedListReloadsCorrectly('Feedlist Reloads Correctly Test');
  });
}
