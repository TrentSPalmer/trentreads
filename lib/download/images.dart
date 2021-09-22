import 'dart:io';
import 'dart:math';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'utils.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getLocalImageFile(
    String _imageUrl, String _imageFile, int _imgFileSize) async {
  String _result = 'none';
  if (!(await multipleStorageDirs())) {
    Directory? _sDir = await getExternalStorageDirectory();
    if (_sDir != null) {
      String _filePath = "${_sDir.path}/images/$_imageFile";
      if (await File(_filePath).exists()) {
        if ((File(_filePath).statSync().size) == _imgFileSize) {
          _result = _filePath;
        }
      }
    }
  } else {
    String _sDirPath = await getSelectedStorageDirectory();
    if (_sDirPath != "not_available") {
      String _filePath = "${_sDirPath}files/images/$_imageFile";
      if (await File(_filePath).exists()) {
        if (File(_filePath).statSync().size == _imgFileSize) {
          _result = _filePath;
          cleanUpDuplicateImageFiles("${_sDirPath}files", _imageFile);
        }
      } else {
        List<Directory>? _sDirs = await getExternalStorageDirectories();
        if (_sDirs != null) {
          await Future.forEach(_sDirs, (Directory _dir) async {
            String _file = "${_dir.path}/images/$_imageFile";
            if (await File(_file).exists()) {
              if (File(_filePath).statSync().size == _imgFileSize) {
                _result = _file;
                copyFileToCorrectLocation(
                    _file, "${_sDirPath}files/images/", _imageFile);
              }
            }
          });
        }
      }
    }
  }
  if (_result == 'none') {
    downloadImageFile(_imageUrl, _imageFile);
  } else {
    cleanUpFileDownLoadQueue(_imageFile);
  }
  checkIncompleteImageDownloads(_imageFile, _imgFileSize);
  return _result;
}

Future<void> checkIncompleteImageDownloads(
    String _imageFile, int _imgFileSize) async {
  List<Directory>? _sDirs = await getExternalStorageDirectories();
  if (_sDirs != null) {
    Future.forEach(_sDirs, (Directory _sDir) async {
      File _file = File("${_sDir.path}/images/$_imageFile");
      if (await _file.exists()) {
        if (await isTwoHoursOld(_file)) {
          removeFromDownLoaderDB(_file);
          if (_file.statSync().size != _imgFileSize) {
            _file.delete();
          }
        }
      }
    });
  }
}

Future<void> cleanUpDuplicateImageFiles(
    String _newFilePath, String _imageFile) async {
  List<Directory>? _sDirs = await getExternalStorageDirectories();
  if (_sDirs != null) {
    List<String> _sDirPaths = _sDirs
        .map((Directory _dir) => _dir.path)
        .where((String _xDir) => (_xDir != _newFilePath))
        .where((String _xDir) =>
            (File("${_xDir}/images/$_imageFile").existsSync()))
        .toList();
    Future.forEach(_sDirPaths, (String _sDirPath) async {
      File("${_sDirPath}/images/$_imageFile").delete();
    });
  }
}

Future<void> downloadImageFile(String _imageUrl, String _imageFile) async {
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
      await createImageDirectory(_sDirPath);
      if (await Directory("${_sDirPath}/images").exists()) {
        if (!(await File("${_sDirPath}/images/$_imageFile").exists())) {
          if (!(await inFileDownloadQueue(_imageFile))) {
            await FlutterDownloader.registerCallback(TestClass.callback);
            FlutterDownloader.enqueue(
              url: _imageUrl,
              savedDir: "${_sDirPath}/images",
              showNotification: false,
              openFileFromNotification: false,
            );
          }
        }
      }
    }
  });
}

Future<void> createImageDirectory(String _sDirPath) async {
  if (!(await Directory("${_sDirPath}/images").exists())) {
    await Directory("${_sDirPath}/images").create(recursive: true);
  }
}
