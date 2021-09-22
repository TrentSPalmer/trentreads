import 'dart:io';
import 'dart:math';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../database/database_helper.dart';
import '../pref_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'utils.dart';

Future<String> getEpisodeMP3(String _mp3Url, String _mp3File, int _mp3FileSize,
    bool _shouldDownLoad, int _fid, bool _shouldCheckMobileDownLoadOK) async {
  String _result = _mp3Url;
  if (!(await multipleStorageDirs())) {
    Directory? _sDir = await getExternalStorageDirectory();
    if (_sDir != null) {
      String _filePath = "${_sDir.path}/audio/$_mp3File";
      if (await File(_filePath).exists()) {
        if ((File(_filePath).statSync().size) == _mp3FileSize) {
          _result = _filePath;
        }
      }
    }
  } else {
    String _sDirPath = await getSelectedStorageDirectory();
    if (_sDirPath != "not_available") {
      String _filePath = await "${_sDirPath}files/audio/$_mp3File";
      if (await File(_filePath).exists()) {
        if (File(_filePath).statSync().size == _mp3FileSize) {
          _result = _filePath;
          cleanUpDuplicateEpisodeFiles("${_sDirPath}files", _mp3File);
        }
      } else {
        List<Directory>? _sDirs = await getExternalStorageDirectories();
        if (_sDirs != null) {
          await Future.forEach(_sDirs, (Directory _dir) async {
            String _file = "${_dir.path}/audio/$_mp3File";
            if (await File(_file).exists()) {
              if ((File(_file).statSync().size) == _mp3FileSize) {
                _result = _file;
                copyFileToCorrectLocation(
                    _file, "${_sDirPath}files/audio/", _mp3File);
              }
            }
          });
        }
      }
    }
  }
  if (_result == _mp3Url && _shouldDownLoad) {
    downloadEpisodeFile(_mp3Url, _mp3File, _fid, _shouldCheckMobileDownLoadOK);
  } else {
    cleanUpFileDownLoadQueue(_mp3File);
  }
  checkIncompleteMP3Downloads(_mp3File, _mp3FileSize);
  return _result;
}

Future<void> cleanUpDuplicateEpisodeFiles(
    String _newFilePath, String _episodeFile) async {
  List<Directory>? _sDirs = await getExternalStorageDirectories();
  if (_sDirs != null) {
    List<String> _sDirPaths = _sDirs
        .map((Directory _dir) => _dir.path)
        .where((String _xDir) => (_xDir != _newFilePath))
        .where((String _xDir) =>
            (File("${_xDir}/audio/$_episodeFile").existsSync()))
        .toList();
    Future.forEach(_sDirPaths, (String _sDirPath) async {
      File("${_sDirPath}/audio/$_episodeFile").delete();
    });
  }
}

Future<void> checkIncompleteMP3Downloads(
    String _mp3File, int _mp3FileSize) async {
  List<Directory>? _sDirs = await getExternalStorageDirectories();
  if (_sDirs != null) {
    Future.forEach(_sDirs, (Directory _sDir) async {
      File _file = File("${_sDir.path}/audio/$_mp3File");
      if (await _file.exists()) {
        if (await isTwoHoursOld(_file)) {
          removeFromDownLoaderDB(_file);
          if (_file.statSync().size != _mp3FileSize) {
            _file.delete();
          }
        }
      }
    });
  }
}

Future<void> downloadEpisodeFile(
  String _mp3Url,
  String _mp3File,
  int _fid,
  bool _shouldCheckMobileDownLoadOK,
) async {
  Random rnd = new Random();
  int r = 1000000 + rnd.nextInt(10000000);
  Future.delayed(Duration(microseconds: r), () async {
    String _sDirPath = 'none';
    if (!(await multipleStorageDirs())) {
      Directory? _sDir = await getExternalStorageDirectory();
      if (_sDir != null) _sDirPath = _sDir.path;
    } else {
      String _selected = await getSelectedStorageDirectory();
      if (_selected != "not_available") _sDirPath = "${_selected}files";
    }
    if (_sDirPath != 'none') {
      await createAudioDirectory(_sDirPath);
      if (await Directory("${_sDirPath}/audio").exists()) {
        if (!(await File("${_sDirPath}/audio/$_mp3File").exists())) {
          if ((!_shouldCheckMobileDownLoadOK) || (await networkDownLoadOK())) {
            final DatabaseHelper dbHelper = await DatabaseHelper.instance;
            if (await dbHelper.shouldDownLoadFeed(_fid)) {
              if (!(await inFileDownloadQueue(_mp3File))) {
                try {
                  await FlutterDownloader.registerCallback(
                      EpisodeDownLoadCallBack.callback);
                } catch (e) {
                  print("Error: $e");
                  await FlutterDownloader.initialize();
                  await FlutterDownloader.registerCallback(
                      EpisodeDownLoadCallBack.callback);
                }

                FlutterDownloader.enqueue(
                  url: _mp3Url,
                  savedDir: "${_sDirPath}/audio",
                  showNotification: false,
                  openFileFromNotification: false,
                );
              }
            }
          }
        }
      }
    }
  });
}

Future<bool> networkDownLoadOK() async {
  if (await getMobileDownLoadOK()) {
    return true;
  } else {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.wifi;
  }
}

Future<void> createAudioDirectory(String _sDirPath) async {
  if (!(await Directory("${_sDirPath}/audio").exists())) {
    await Directory("${_sDirPath}/audio").create(recursive: true);
  }
}
