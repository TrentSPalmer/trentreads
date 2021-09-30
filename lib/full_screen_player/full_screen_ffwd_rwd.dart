import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

IconButton fullScreenRwd() {
  return IconButton(
    onPressed: () {
      AudioService.rewind();
    },
    icon: Icon(Icons.fast_rewind),
    iconSize: 64.0,
  );
}

IconButton fullScreenFfwd() {
  return IconButton(
    onPressed: () {
      AudioService.fastForward();
      AudioService.fastForward();
      AudioService.fastForward();
    },
    icon: Icon(Icons.fast_forward),
    iconSize: 64.0,
  );
}
