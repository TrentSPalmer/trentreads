import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../player/audio_player.dart';
import '../pref_utils.dart';

class EpisodePlayButton extends StatefulWidget {
  final int episodeID;
  final String episodeTitle;
  final String feedTitle;
  final int currentEpisode;
  final Function() updateCurrentEpisode;

  EpisodePlayButton({
    Key? key,
    required this.episodeID,
    required this.episodeTitle,
    required this.feedTitle,
    required this.currentEpisode,
    required this.updateCurrentEpisode,
  }) : super(key: key);

  @override
  EpisodePlayButtonState createState() => EpisodePlayButtonState();
}

class EpisodePlayButtonState extends State<EpisodePlayButton> {
  bool active = false;

  @override
  void initState() {
    super.initState();
    getCurrentEpisode().then((value) => {
          if (value == widget.episodeID)
            {
              setState(() {
                active = true;
              })
            }
        });
  }

  void activateTrack() async {
    setCurrentEpisode(widget.episodeID).then((val) {
      if (!AudioService.running) {
        restartPlayer();
      } else {
        AudioService.play();
      }
      if (!active) {
        setState(() {
          active = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color _alternateIconColor = active ? Colors.black87 : appColors.candyApple;
    return StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, snapshot) {
          if ((snapshot.connectionState != ConnectionState.active) ||
              (!active)) {
            getCurrentEpisode().then((int currentEpisode) {
              if (currentEpisode == widget.episodeID) {
                setState(() {
                  active = true;
                });
              }
            });
            return IconButton(
              onPressed: () async {
                activateTrack();
              },
              icon: Icon(Icons.play_circle_outline),
              iconSize: 32.0,
              color: _alternateIconColor,
              autofocus: true,
            );
          }
          return StreamBuilder<bool>(
            stream: AudioService.playbackStateStream
                .map((state) => state.playing)
                .distinct(),
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return StreamBuilder<MediaItem?>(
                stream: AudioService.currentMediaItemStream,
                builder: (context, snapshot) {
                  widget.updateCurrentEpisode();
                  String _t = snapshot.data?.title ?? widget.episodeTitle;
                  String _a = snapshot.data?.album ?? widget.feedTitle;
                  if (_t != widget.episodeTitle || _a != widget.feedTitle) {
                    return IconButton(
                      onPressed: () async {
                        activateTrack();
                      },
                      icon: Icon(Icons.play_circle_outline),
                      iconSize: 32.0,
                      color: appColors.candyApple,
                      autofocus: true,
                    );
                  } else {
                    if (playing) {
                      return IconButton(
                        onPressed: () async {
                          AudioService.pause();
                        },
                        icon: Icon(Icons.pause_circle_outline),
                        iconSize: 32.0,
                        autofocus: true,
                      );
                    } else {
                      return IconButton(
                        onPressed: () async {
                          activateTrack();
                        },
                        icon: Icon(Icons.play_circle_outline),
                        iconSize: 32.0,
                        autofocus: true,
                      );
                    }
                  }
                },
              );
            },
          );
        });
  }
}
