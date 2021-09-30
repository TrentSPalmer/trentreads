import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../full_screen_player/full_screen_player.dart';
import '../player/audio_player.dart';
import '../pref_utils.dart';

class MiniPlayer extends StatefulWidget {
  @override
  MiniPlayerState createState() => MiniPlayerState();
}

Future<void> activateTrack() async {
  if (AudioService.running) {
    await AudioService.play();
  } else {
    await restartPlayer();
  }
}

class MiniPlayerState extends State<MiniPlayer> {
  String _episodeTitle = 'none';

  void checkTitle() {
    getCurrentEpisodeTitle().then((String _eName) {
      if (_eName != _episodeTitle && mounted) {
        setState(() {
          _episodeTitle = _eName;
        });
      }
    });
  }

  Future<void> goToFullScreenPlayer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPlayer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 3.0,
      ),
      child: Container(
        decoration: myBoxDecoration(appColors.ivory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              goToFullScreenPlayer();
            },
            child: Padding(
              padding: EdgeInsets.all(12.0),
              // child: Text("foo"),
              child: StreamBuilder<bool>(
                stream: AudioService.runningStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    checkTitle();
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            _episodeTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await activateTrack();
                          },
                          icon: Icon(Icons.play_circle_outline),
                          iconSize: 32.0,
                          color: appColors.candyApple,
                        ),
                      ],
                    );
                  } else {
                    return StreamBuilder<bool>(
                      stream: AudioService.playbackStateStream
                          .map((state) => state.playing)
                          .distinct(),
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return StreamBuilder<MediaItem?>(
                          stream: AudioService.currentMediaItemStream,
                          builder: (context, snapshot) {
                            String _title = snapshot.data?.title ?? '';
                            if (_title == '') {
                              _title = _episodeTitle;
                              checkTitle();
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (playing) ...[
                                  IconButton(
                                    onPressed: () async {
                                      await AudioService.pause();
                                    },
                                    icon: Icon(Icons.pause_circle_outline),
                                    iconSize: 32.0,
                                  ),
                                ] else ...[
                                  IconButton(
                                    onPressed: () async {
                                      await activateTrack();
                                    },
                                    icon: Icon(Icons.play_circle_outline),
                                    iconSize: 32.0,
                                  ),
                                ]
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
