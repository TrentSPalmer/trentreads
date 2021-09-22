import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import '../player/media_library.dart';
import 'package:just_audio/just_audio.dart';
import 'seeker.dart';
import '../pref_utils.dart';

void audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  int _position = 0;
  AudioPlayer _player = new AudioPlayer();
  AudioProcessingState? _skipState;
  Seeker? _seeker;
  late StreamSubscription<PlaybackEvent> _eventSubscription;
  late StreamSubscription<int?> _currentItemIndexSubscription;
  late StreamSubscription<Duration?> _currentDurationSubscription;
  late StreamSubscription<int?> _currentMediaItemSubscription;
  late StreamSubscription<Duration?> _playerPositionSubscription;

  int? get index => _player.currentIndex;

  Future<void> cancelStreams() async {
    await _eventSubscription.cancel();
    await _currentItemIndexSubscription.cancel();
    await _currentDurationSubscription.cancel();
    await _playerPositionSubscription.cancel();
  }

  Future<void> setUpMediaItemSubscription() async {
    // this subscription handles cases where the player reaches the
    // end of a track and proceeds automatically to the next one
    // therefore this subscription is started last and stopped first
    _currentMediaItemSubscription =
        _player.currentIndexStream.listen((int? _streamIndex) async {
      List<MediaItem>? _playingQueue = await AudioServiceBackground.queue;
      if (_streamIndex != null && _playingQueue != null && _streamIndex > -1) {
        int _oldM = _streamIndex > 0 ? _streamIndex - 1 : _playingQueue.length - 1;
        MediaItem _mI = await getCurrentMediaItem();
        if (areMediaItemsEqual(_mI, _playingQueue[_oldM])) {
          await updatePSeconds(
              0, _playingQueue[_oldM].title, _playingQueue[_oldM].album);
          await updateCurrentEpisode(
              _playingQueue[_streamIndex].title, _playingQueue[_streamIndex].album);
          int _pS = await getPSecondsFromNames(
              _playingQueue[_streamIndex].album, _playingQueue[_streamIndex].title);
          await _player.seek(Duration(seconds: _pS));
        }
      }
    });
  }

  Future<void> setUp(List<MediaItem> queue) async {
    _currentItemIndexSubscription = _player.currentIndexStream.listen((index) {
      if (index != null && index != -1 && index < queue.length)
        AudioServiceBackground.setMediaItem(queue[index]);
    });

    _currentDurationSubscription =
        _player.durationStream.listen((Duration? _dur) {
      int songIndex = _player.playbackEvent.currentIndex ?? -1;
      Duration _d = _dur ?? Duration.zero;
      if (_dur != null && songIndex != -1 && songIndex < queue.length) {
        MediaItem _cMI = queue[songIndex];
        final modifiedMediaItem = MediaItem(
          id: _cMI.id,
          album: _cMI.album,
          title: _cMI.title,
          duration: _d,
        );
        queue[songIndex] = modifiedMediaItem;
        AudioServiceBackground.setMediaItem(queue[songIndex]);
        AudioServiceBackground.setQueue(queue);
      }
    });

    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          onStop();
          break;
        case ProcessingState.ready:
          _skipState = null;
          break;
        default:
          break;
      }
    });

    int _pSeconds = await getPSeconds();
    String currentMediaID = await getCurrentMediaID();
    int playIndex = queue.indexWhere((item) => item.id == currentMediaID);
    try {
      await _player.setAudioSource(
          ConcatenatingAudioSource(
            children: queue
                .map((item) => AudioSource.uri(Uri.parse(item.id)))
                .toList(),
          ),
          initialIndex: playIndex,
          initialPosition: Duration(seconds: _pSeconds));
      await _player.setLoopMode(LoopMode.all);
      _player.play();
    } catch (e) {
      print("Error: $e");
      onStop();
    }

    _playerPositionSubscription =
        _player.positionStream.listen((Duration _p) async {
      int _pSeconds = _player.position.inSeconds;
      if (_pSeconds != _position) {
        _position = _pSeconds;
        if (_pSeconds % 4 == 0 && _pSeconds > 5) {
          await updatePSecondsByEid(_pSeconds);
        }
      }
    });

    await setUpMediaItemSubscription();
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    await _currentMediaItemSubscription.cancel();

    List<MediaItem>? oldqueue = await AudioServiceBackground.queue;
    List<MediaItem> queue = await getQueue();

    int newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) {
      await _player.stop();
      await cancelStreams();

      await setUp(queue);
    } else {
      await setNewCurrentEpisode(queue[newIndex].album, queue[newIndex].title);
      List<MediaItem> newqueue = await getQueue();
      if (areEqualQueues(oldqueue, newqueue)) {
        _skipState = newIndex > index!
            ? AudioProcessingState.skippingToNext
            : AudioProcessingState.skippingToPrevious;
        int _pSeconds = await getPSeconds();
        await _player.seek(Duration(seconds: _pSeconds), index: newIndex);
        await setUpMediaItemSubscription();
      } else {
        await _player.stop();
        await cancelStreams();

        await setUp(newqueue);
      }
    }

    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onPlay() async {
    await _currentMediaItemSubscription.cancel();
    List<MediaItem>? oldqueue = await AudioServiceBackground.queue;
    List<MediaItem> queue = await getQueue();

    if (areEqualQueues(oldqueue, queue)) {
      int _pSeconds = await getPSeconds();
      String currentMediaID = await getCurrentMediaID();
      int playIndex = queue.indexWhere((item) => item.id == currentMediaID);
      await _player.seek(Duration(seconds: _pSeconds), index: playIndex);
      await _player.play();
      await setUpMediaItemSubscription();
    } else {
      await _player.stop();
      await cancelStreams();

      await setUp(queue);
    }
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    List<MediaItem> queue = await getQueue();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    await setUp(queue);
  }

  @override
  Future<void> onPause() async {
    await _currentMediaItemSubscription.cancel();
    _player.pause();
  }

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    // await updatePSeconds(_player.position.inSeconds);
    await _player.dispose();
    await cancelStreams();
    await _currentMediaItemSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > _player.duration!) newPosition = _player.duration!;
    await _player.seek(newPosition);
  }

  void _seekContinuously(bool begin, int direction) {
    // _seeker?.stop();
    // if (begin) {
    //   _seeker = Seeker(_player, Duration(seconds: 10 * direction),
    //       Duration(seconds: 1), mediaItem!)
    //     ..start();
    // }
  }

  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState!;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

Future<void> restartPlayer() async {
  await AudioService.start(
    backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
    androidNotificationChannelName: 'Trent Reads',
    androidNotificationColor: 0xFF2196f3,
    androidNotificationIcon: 'mipmap/trent_reads_launcher',
    androidEnableQueue: true,
  );
}
