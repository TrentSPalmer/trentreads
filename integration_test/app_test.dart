import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'about_feed_load_test.dart';
import 'about_screen_load_test.dart';
import 'download_setting_loadtest.dart';
import 'feedlist_needs_refreshing.dart';
import 'feedlist_reloads_correctly_test.dart';
import 'home_screen_load_test.dart';
import 'network_setting_loadtest.dart';
import 'setting_screen_loadtest.dart';
import 'storage_setting_loadtest.dart';

final String feedsLastUpdatedAt = 'feedsLastUpdatedAt';

void main() {
  group('TrentReads Load Test', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;

    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

    homeScreenLoadTest('HomeScreen Load Test');
    feedListNeedsRefreshing('FeedList Needs Refreshing Test');
    aboutFeedsLoadTest("About Feeds Load Test");
    settingScreenLoadTest("Setting Screen Load Test");
    storageSettingLoadTest("Storage Setting Load Test");
    downloadSettingLoadTest("DownLoad Setting Load Test");
    networkSettingLoadTest("Network Setting Load Test");
    aboutScreenLoadTest("About Screen Load Test");
    feedListReloadsCorrectly('Feedlist Reloads Correctly Test');
  });
}
