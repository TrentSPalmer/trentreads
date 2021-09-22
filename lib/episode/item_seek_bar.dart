import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../pref_utils.dart';
import 'package:rxdart/rxdart.dart';
import '../player/seek_bar.dart';

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class ItemSeekBar extends StatelessWidget {
  final String episodeTitle;
  final String feedTitle;
  final bool fullScreen;

  ItemSeekBar({
    Key? key,
    required this.feedTitle,
    required this.episodeTitle,
    required this.fullScreen,
  }) : super(key: key);

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => MediaState(mediaItem, position));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AudioService.runningStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return Container(height: (this.fullScreen) ? 48.0 : 0,);
        }
        final running = snapshot.data ?? false;
        if (!running) {
          return Container(height: (this.fullScreen) ? 48.0 : 0,);
        } else {
          return StreamBuilder<MediaState>(
            stream: _mediaStateStream,
            builder: (context, snapshot) {
              final mediaState = snapshot.data;
              String _t = mediaState?.mediaItem?.title ?? '';
              String _a = mediaState?.mediaItem?.album ?? '';
              if (_t != episodeTitle || _a != feedTitle) {
                return Container(height: (this.fullScreen) ? 48.0 : 0,);
              } else {
                Duration duration =
                    mediaState?.mediaItem?.duration ?? Duration.zero;
                Duration position = mediaState?.position ?? Duration.zero;
                return Row(
                  children: [
                    Text("${getHumanReadableDuration(position)}"),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbColor: appColors.navy,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: appColors.navy,
                          inactiveTrackColor: appColors.peacockBlue,
                        ),
                        child: SeekBar(
                          duration: duration,
                          position: position,
                          onChanged: (Duration newPosition) {
                            if (AudioService.playbackState.playing) {
                              AudioService.seekTo(newPosition);
                            } else {
                              setNewPlayPosition(newPosition.inSeconds);
                            }
                          },
                        ),
                      ),
                    ),
                    Text("${getHumanReadableDuration(duration)}"),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }
}
