import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../mini_player/mini_player.dart';

Expanded FullPlayerPlayPause() {
  return Expanded(
    child: FittedBox(
      child: StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return IconButton(
              onPressed: () async {
                await activateTrack();
              },
              icon: Icon(Icons.play_circle_fill),
            );
          } else {
            return StreamBuilder<bool>(
              stream: AudioService.playbackStateStream
                  .map((state) => state.playing)
                  .distinct(),
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                if (playing) {
                  return IconButton(
                    onPressed: () async {
                      await AudioService.pause();
                    },
                    icon: Icon(Icons.pause_circle_filled),
                  );
                } else {
                  return IconButton(
                    onPressed: () async {
                      await activateTrack();
                    },
                    icon: Icon(Icons.play_circle_fill),
                  );
                }
              },
            );
          }
        },
      ),
    ),
  );
}
