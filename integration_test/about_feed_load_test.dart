import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_info/storage_info.dart';

import '../lib/download/utils.dart';
import '../lib/home/feeds.dart';
import '../lib/main.dart';
import 'setting_screen_loadtest.dart';

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
        await verifyAppBarTitle(
            tester, "Options: ${myFeedState.feedList[i].title}");
        await testFeedDesc(i, tester, myFeedState.feedList[i].desc);
        await testFeedImageDesc(i, tester, myFeedState.feedList[i].imageDesc);
        await testFeedLocalImage(tester, myFeedState.feedList[i].imageFileName);
        await clickBackButton(tester);
      }
    });

Future<void> testFeedLocalImage(WidgetTester tester, String _fileName) async {
  Finder feediLocalImageFinder = find.byKey(Key('feed_local_image'));
  expect(feediLocalImageFinder, findsOneWidget);
  Image feedILocalImage =
      feediLocalImageFinder.evaluate().single.widget as Image;
  String _sDirPath = await getSDir();
  String feedILocalImageImage = feedILocalImage.image.toString();
  String feedILocalImagePath =
      'FileImage("${_sDirPath}/images/${_fileName}", scale: 1.0)';
  // print(feedILocalImageImage); print(feedILocalImagePath);
  expect(feedILocalImageImage == feedILocalImagePath, true);
}

Future<String> getSDir() async {
  String _sDirPath = await getSelectedStorageDirectory();
  if (_sDirPath != "not_available") {
    return "${_sDirPath}files";
  } else {
    if (!(await multipleStorageDirs())) {
      Directory? _sDir = await getExternalStorageDirectory();
      return (_sDir != null) ? "${_sDir.path}" : "not_available";
    } else {
      List<Directory>? _storageDirs = await getExternalStorageDirectories();
      if (_storageDirs == null) {
        return "not_available";
      } else {
        double _exFree = await StorageInfo.getExternalStorageFreeSpaceInGB;
        double _inFree = await StorageInfo.getStorageFreeSpaceInGB;
        return (_exFree > _inFree)
            ? "${_storageDirs[1].path}"
            : "${_storageDirs[0].path}";
      }
    }
  }
}

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
  Container feedInkWell = inkWelliFinder.evaluate().single.widget as Container;
  Finder infoIconIFinder = find.descendant(
    of: find.byWidget(feedInkWell),
    matching: find.byType(IconButton),
  );
  expect(infoIconIFinder, findsOneWidget);
  IconButton infoIIconButton =
      infoIconIFinder.evaluate().single.widget as IconButton;
  await tester.tap(find.byWidget(infoIIconButton));
  await tester.pumpAndSettle();
}
