import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_info/storage_info.dart';

import '../database/database_helper.dart';

class TestClass {
  static void callback(String id, DownloadTaskStatus status, int progress) {}
}

class EpisodeDownLoadCallBack {
  static Future<void> callback(
      String id, DownloadTaskStatus status, int progress) async {}
}

Future<bool> checkStorageSelected(List<Directory> _storageDirs) async {
  List<String> _sdPaths = _storageDirs
      .map((Directory _dir) => _dir.path.substring(0, _dir.path.length - 5))
      .toList();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? _selectedStorageDevice = prefs.getString("SelectedStorageDevice");
  return _selectedStorageDevice == null
      ? false
      : _sdPaths.contains(_selectedStorageDevice);
}

Future<bool> inFileDownloadQueue(String _file) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  return (await dbHelper.inFileDownloadQueue(_file));
}

Future<void> cleanUpFileDownLoadQueue(String _file) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  await dbHelper.cleanUpFileDownLoadQueue(_file);
}

Future<void> setDefaultStorageDevice(List<Directory> _storDirs) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double _exFree = await StorageInfo.getExternalStorageFreeSpaceInGB;
  double _inFree = await StorageInfo.getStorageFreeSpaceInGB;
  if (_exFree > _inFree) {
    await prefs.setString("SelectedStorageDevice",
        _storDirs[1].path.substring(0, _storDirs[1].path.length - 5));
  } else {
    await prefs.setString("SelectedStorageDevice",
        _storDirs[0].path.substring(0, _storDirs[0].path.length - 5));
  }
}

Future<String> getSelectedStorageDirectory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? _selectedStorageDevice = prefs.getString("SelectedStorageDevice");
  return _selectedStorageDevice ?? "not_available";
}

Future<bool> multipleStorageDirs() async {
  List<Directory>? _storageDirs = await getExternalStorageDirectories();
  if (_storageDirs != null) {
    if ((_storageDirs.length > 1) &&
        (!await checkStorageSelected(_storageDirs))) {
      await setDefaultStorageDevice(_storageDirs);
    }
    return _storageDirs.length > 1;
  }
  return false;
}

Future<bool> isTwoHoursOld(File _file) async {
  int _currentTime = DateTime.now().millisecondsSinceEpoch ~/ 10000;
  int _fModTime = (await _file.lastModified()).millisecondsSinceEpoch ~/ 10000;
  return (_currentTime - _fModTime) > 7200;
}

Future<void> removeFromDownLoaderDB(File _file) async {
  List<DownloadTask> _dlTasks;
  try {
    _dlTasks = (await FlutterDownloader.loadTasks() ?? []);
  } catch (e) {
    print("Error: $e");
    await FlutterDownloader.initialize();
    _dlTasks = (await FlutterDownloader.loadTasks() ?? []);
  }
  _dlTasks
      .where((DownloadTask _task) =>
          _file.path == "${_task.savedDir}/${_task.filename}")
      .forEach((DownloadTask _taskX) {
    FlutterDownloader.remove(taskId: _taskX.taskId, shouldDeleteContent: false);
  });
}

Future<void> copyFileToCorrectLocation(
    String _filePath, String _destination, String _file) async {
  if (!(await Directory(_destination).exists())) {
    await Directory(_destination).create(recursive: true);
  }
  File(_filePath).copy("${_destination}$_file");
}
