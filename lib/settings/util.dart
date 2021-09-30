import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';
import '../feed_options/util.dart' show deleteFeedEpisodes;

Future<int> getGlobalNumDownLoadedEpisodes() async {
  int _result = 0;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  int _totalEpisodes = await dbHelper.getGlobalNumEpisodes();
  for (int i = 0; i < _totalEpisodes; i++) {
    String _mp3 = await dbHelper.getNthMP3(i);
    int _mp3FileSize = await dbHelper.getMP3Size(_mp3);
    if (await isDownloaded(_mp3, _mp3FileSize)) _result++;
  }
  return _result;
}

Future<int> deleteAllEpisodes() async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  int _totalFeeds = await dbHelper.getNumFeeds();
  for (int i = 0; i < _totalFeeds; i++) {
    int _fid = await dbHelper.getNthFeed(i);
    await deleteFeedEpisodes(_fid, true);
  }
  return 1;
}

Future<bool> isDownloaded(String _mp3, int _mp3FileSize) async {
  bool _result = false;
  List<Directory> _sDirs = (await getExternalStorageDirectories()) ?? [];
  await Future.forEach(_sDirs, (Directory _sDir) async {
    if (!_result) {
      File _file = File("${_sDir.path}/audio/$_mp3");
      if (_file.existsSync()) {
        if (_file.statSync().size == _mp3FileSize) _result = true;
      }
    }
  });
  return _result;
}
