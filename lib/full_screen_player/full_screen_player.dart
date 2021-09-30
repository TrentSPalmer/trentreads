import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../pref_utils.dart';
import 'full_player_play_pause.dart';
import 'full_screen_ffwd_rwd.dart';
import 'full_screen_player_seek_bar.dart';
import 'full_screen_skip_previous_next.dart';

class FullScreenPlayer extends StatefulWidget {
  @override
  FullScreenPlayerState createState() => FullScreenPlayerState();
}

class FullScreenPlayerState extends State<FullScreenPlayer> {
  String _episodeTitle = 'none';

  void checkTitle() {
    getCurrentEpisodeTitle().then((String _eName) {
      if (_eName != _episodeTitle) {
        setState(() {
          _episodeTitle = _eName;
        });
      }
    });
  }

  void updateTitle(String _title) {
    setCurrentEpisodeByName(_title).then((x) => {checkTitle()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text(_episodeTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(3.0),
        child: Container(
          decoration: myBoxDecoration(appColors.ivory),
          child: Padding(
            padding: EdgeInsets.all(3.0),
            child: StreamBuilder<bool>(
              stream: AudioService.runningStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.active) {
                  checkTitle();
                  return fullPlayerColumn(false);
                } else {
                  final running = snapshot.data ?? false;
                  return StreamBuilder<MediaItem?>(
                    stream: AudioService.currentMediaItemStream,
                    builder: (context, snapshot) {
                      String _title = snapshot.data?.title ?? '';
                      if (_title == '') {
                        _title = _episodeTitle;
                        checkTitle();
                      } else {
                        updateTitle(_title);
                      }
                      return fullPlayerColumn(running);
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Column fullPlayerColumn(bool _running) {
    return Column(
      children: [
        FullPlayerPlayPause(),
        FullScreenPlayerSeekBar(),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  fullScreenSkipPrevious(checkTitle),
                  if (_running) ...[
                    fullScreenRwd(),
                    fullScreenFfwd(),
                  ],
                  fullScreenSkipNext(checkTitle),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
