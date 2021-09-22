import 'package:flutter/material.dart';
import '../database/data_classes.dart';
import '../pref_utils.dart';
import 'episode_downloaders.dart';

abstract class FuncMixin<T extends StatefulWidget> extends State<T> {
  List<ScrollableEpisode> episodeList = [];
  ScrollController? scrollController;

  @visibleForTesting
  Future<void> reloadEpisodes(_fid) async {
    getEpisodeList(_fid).then((value) => {
          if (mounted)
            setState(() {
              episodeList = value;
            })
        });
  }

  int verifiedEpisodeListLength(int _currentFeedID) {
    if (episodeList.length == 0) {
      return 0;
    } else {
      return (_currentFeedID == episodeList[0].feedID) ? episodeList.length : 0;
    }
  }

  Future<void> _checkEpisodesChanged(_fid) async {
    if (await fetchEpisodes(_fid)) {
      reloadEpisodes(_fid);
    }
  }

  Future<void> checkEpisodesExpired(int _fid) async {
    if (_fid > -1) {
      if (await lastFeedUpdateExpired(_fid)) {
        _checkEpisodesChanged(_fid);
      }
    }
  }

  Future<ScrollableEpisode> getRow(int row) async {
    return episodeList[row];
  }
}
