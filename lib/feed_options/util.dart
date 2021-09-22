import 'package:audio_service/audio_service.dart';
import '../database/data_classes.dart';
import '../download/episode_download.dart';
import '../download/utils.dart';
import '../database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<int> getNumDownLoadedEpisodes(_fid) async {
  int _result = 0;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<ScrollableEpisode> _episodes =
      await dbHelper.getScrollableEpisodeList(_fid);
  await Future.forEach(_episodes, (ScrollableEpisode _episode) async {
    if (await episodeFound(_episode.mp3File, _episode.mp3FileSize)) _result++;
  });
  return _result;
}

Future<int> downLoadFeedEpisode(int _fid) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  await dbHelper.markShouldDownLoadFeed(_fid, true);
  List<ScrollableEpisode> _episodes =
      await dbHelper.getScrollableEpisodeList(_fid);
  _episodes.forEach((ScrollableEpisode _episode) {
    getEpisodeMP3(
      _episode.mp3Url,
      _episode.mp3File,
      _episode.mp3FileSize,
      true,
      _fid,
      false,
    );
  });
  return 1;
}

Future<int> deleteFeedEpisodes(int _fid, bool _shouldDisable) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  if (_shouldDisable) await dbHelper.markShouldDownLoadFeed(_fid, false);
  List<ScrollableEpisode> _episodes =
      await dbHelper.getScrollableEpisodeList(_fid);
  List<String> _mp3s =
      _episodes.map((ScrollableEpisode _ep) => _ep.mp3File).toList();
  List<Directory> _sDirs = (await getExternalStorageDirectories()) ?? [];
  await Future.forEach(_episodes, (ScrollableEpisode _episode) async {
    await Future.forEach(_sDirs, (Directory _sDir) async {
      String _filePath = "${_sDir.path}/audio/${_episode.mp3File}";
      if (await File(_filePath).exists()) {
        if (((File(_filePath).statSync().size) == _episode.mp3FileSize) ||
            (await isTwoHoursOld(File(_filePath)))) {
          await removeFromDownLoaderDB(File(_filePath));
          await cleanUpFileDownLoadQueue(_episode.mp3File);
          await File(_filePath).delete();
          stopPlayer(_mp3s);
        }
      }
    });
  });
  return 1;
}

Future<void> stopPlayer(List<String> _mp3s) async {
  if (AudioService.playbackState.playing) {
    _mp3s.forEach((String _mp3) {
      if (AudioService.currentMediaItem!.id.contains(_mp3)) {
        AudioService.stop();
      }
    });
  }
}

Future<bool> episodeFound(String _mp3File, int _mp3FileSize) async {
  bool _result = false;
  List<Directory> _sDirs = await getExternalStorageDirectories() ?? [];
  _sDirs.forEach((Directory _sDir) {
    if (File("${_sDir.path}/audio/$_mp3File").existsSync()) {
      if (File("${_sDir.path}/audio/$_mp3File").statSync().size ==
          _mp3FileSize) {
        _result = true;
      }
    }
  });
  return _result;
}
