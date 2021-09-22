import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../episode/item_seek_bar.dart';
import '../pref_utils.dart';

class FullScreenPlayerSeekBar extends StatefulWidget {
  @override
  FullScreenPlayerSeekBarState createState() => FullScreenPlayerSeekBarState();
}

class FullScreenPlayerSeekBarState extends State<FullScreenPlayerSeekBar> {
  String _episodeTitle = 'none';
  String _feedTitle = 'none';

  void checkTitles() {
    getCurrentEpisodeTitle().then((String _eName) {
      getCurrentFeedTitle().then((String _fName) {
        if (_eName != _episodeTitle || _fName != _feedTitle) {
          if (mounted) {
            setState(() {
              _episodeTitle = _eName;
              _feedTitle = _fName;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_episodeTitle == 'none' || _feedTitle == '') {
      checkTitles();
      return ItemSeekBar(
        feedTitle: _feedTitle,
        episodeTitle: _episodeTitle,
        fullScreen: true,
      );
    } else {
      return StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            checkTitles();
            return ItemSeekBar(
              feedTitle: _feedTitle,
              episodeTitle: _episodeTitle,
              fullScreen: true,
            );
          } else {
            return StreamBuilder<MediaItem?>(
              stream: AudioService.currentMediaItemStream,
              builder: (context, snapshot) {
                checkTitles();
                return ItemSeekBar(
                  feedTitle: _feedTitle,
                  episodeTitle: _episodeTitle,
                  fullScreen: true,
                );
              },
            );
          }
        },
      );
    }
  }
}
