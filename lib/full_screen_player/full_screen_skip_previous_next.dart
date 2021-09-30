import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../database/data_classes.dart';
import '../episode/episode_downloaders.dart';
import '../pref_utils.dart';

Future<String> setCurrentEpisodeToPrevious() async {
  int _eid = await getCurrentEpisode();
  int _fid = await getCurrentFeedID();
  List<ScrollableEpisode> _episodeList = await getEpisodeList(_fid);
  int _currentIndex = _episodeList.indexWhere((item) => item.id == _eid);
  int _previousIndex =
      (_currentIndex > 0) ? _currentIndex - 1 : _episodeList.length - 1;
  int _previousEpisode = _episodeList[_previousIndex].id;
  String _previousEpisodeTitle = _episodeList[_previousIndex].title;
  await setCurrentEpisode(_previousEpisode);
  return _previousEpisodeTitle;
}

IconButton fullScreenSkipPrevious(VoidCallback checkTitle) {
  return IconButton(
    onPressed: () {
      if (AudioService.running) {
        if (AudioService.playbackState.position.inSeconds > 5) {
          AudioService.seekTo(Duration(seconds: 0));
        } else {
          AudioService.skipToPrevious();
        }
      } else {
        setCurrentEpisodeToPrevious().then((String _eTitle) => {
              setCurrentEpisodeByName(_eTitle).then((x) => {checkTitle()})
            });
      }
    },
    icon: Icon(Icons.skip_previous),
    iconSize: 64.0,
  );
}

Future<String> setCurrentEpisodeToNext() async {
  int _eid = await getCurrentEpisode();
  int _fid = await getCurrentFeedID();
  List<ScrollableEpisode> _episodeList = await getEpisodeList(_fid);
  int _currentIndex = _episodeList.indexWhere((item) => item.id == _eid);
  int _nextIndex =
      (_currentIndex < _episodeList.length - 1) ? _currentIndex + 1 : 0;
  int _nextEpisode = _episodeList[_nextIndex].id;
  String _nextEpisodeTitle = _episodeList[_nextIndex].title;
  await setCurrentEpisode(_nextEpisode);
  return _nextEpisodeTitle;
}

IconButton fullScreenSkipNext(VoidCallback checkTitle) {
  return IconButton(
    onPressed: () {
      if (AudioService.running) {
        AudioService.skipToNext();
      } else {
        setCurrentEpisodeToNext().then((String _eTitle) => {
              setCurrentEpisodeByName(_eTitle).then((x) => {checkTitle()})
            });
      }
    },
    icon: Icon(Icons.skip_next),
    iconSize: 64.0,
  );
}
