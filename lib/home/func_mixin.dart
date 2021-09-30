import 'package:flutter/material.dart';

import '../database/data_classes.dart';
import '../home/feed_downloaders.dart';
import '../pref_utils.dart';

abstract class FuncMixin<T extends StatefulWidget> extends State<T> {
  @visibleForTesting
  List<ScrollableFeed> feedList = [];
  ScrollController? scrollController;

  @visibleForTesting
  Future<void> reloadFeeds() async {
    getFeedList().then((value) => {
          setState(() {
            feedList = value;
          })
        });
  }

  Future<void> _checkFeedsChanged() async {
    if (await fetchFeeds()) {
      reloadFeeds();
    }
  }

  Future<void> checkFeedsExpired() async {
    if (await lastFeedsUpdateExpired()) {
      _checkFeedsChanged();
    }
  }

  Future<ScrollableFeed> getRow(int row) async {
    return feedList[row];
  }

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
    getFeedList()
        .then((value) => {
              setState(() {
                feedList = value;
              })
            })
        .then((value) => {checkFeedsExpired()});
  }
}
