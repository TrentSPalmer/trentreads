import 'dart:io';
import '../widgets.dart';

import '../download/utils.dart';
import '../pref_utils.dart';
import '../constants.dart';
import 'package:storage_info/storage_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class StorageSetting extends StatefulWidget {
  @override
  StorageSettingState createState() => StorageSettingState();
}

enum StorageDev { internal, external }

class StorageSettingState extends State<StorageSetting> {
  StorageDev? _storageDev = StorageDev.internal;
  bool multipleDirs = false;
  List<String> storDirPaths = [];

  // String _selectedStorageDir = '';
  double _externalFree = 0.0;
  double _externalTotal = 0.0;
  double _internalFree = 0.0;
  double _internalTotal = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('Storage'),
      ),
      body: Column(
        children: [
          _internalSettingItem(),
          if (multipleDirs) ...[
            _settingItem(
                _settingItemTitle(
                  storDirPaths[1],
                  _externalFree,
                  _externalTotal,
                ),
                StorageDev.external,
                "external_storage_device"),
          ],
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              homeButton(context, 2),
              Expanded(
                child: Container(),
              ),
              okButton(context, 1),
            ],
          ),
        ],
      ),
    );
  }

  Padding _internalSettingItem() {
    return _settingItem(
        _settingItemTitle(
          storDirPaths.length > 0 ? storDirPaths[0] : "waiting for devices",
          _internalFree,
          _internalTotal,
        ),
        StorageDev.internal,
        "internal_storage_device");
  }

  Text _settingItemTitle(String _dev, double _free, double _total) {
    String _devString = _dev.contains('Android')
        ? _dev.substring(0, _dev.indexOf('Android'))
        : _dev;
    String _space = "${_free.round()} of ${_total.round()} GB free";
    return Text("$_devString\n$_space");
  }

  Padding _settingItem(Text _title, StorageDev _value, String _key) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 3.0,
      ),
      child: Container(
        decoration: myBoxDecoration(appColors.ivory),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: RadioListTile<StorageDev>(
            key: Key('${_key}_radio_list_tile'),
            title: _title,
            value: _value,
            groupValue: _storageDev,
            activeColor: appColors.peacockBlue,
            onChanged: (StorageDev? value) {
              _updateStoragePref(value);
              setState(() {
                _storageDev = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateStoragePref(StorageDev? _sDev) async {
    if (_sDev != null && storDirPaths.length > 1) {
      String _path = storDirPaths[_sDev == StorageDev.internal ? 0 : 1];
      await setStoragePref(_path);
    }
  }

  void getInTotal(List<String> _sdPaths, String _selectedStorDir,
      double _exFree, double _exTotal, double _inFree) {
    StorageInfo.getStorageTotalSpaceInGB.then((double _inTotal) => {
          if (_inTotal != null)
            {
              setState(() {
                multipleDirs = true;
                storDirPaths = _sdPaths;
                // _selectedStorageDir = _selectedStorDir;
                _externalFree = _exFree;
                _externalTotal = _exTotal;
                _internalFree = _inFree;
                _internalTotal = _inTotal;
                _storageDev = _selectedStorDir == storDirPaths[0]
                    ? StorageDev.internal
                    : StorageDev.external;
              })
            }
        });
  }

  void getInFree(List<String> _sdPaths, String _selectedStorDir, double _exFree,
      double _exTotal) {
    StorageInfo.getStorageFreeSpaceInGB.then((double _inFree) => {
          if (_inFree != null)
            {getInTotal(_sdPaths, _selectedStorDir, _exFree, _exTotal, _inFree)}
        });
  }

  void getExTotal(
      List<String> _sdPaths, String _selectedStorDir, double _exFree) {
    StorageInfo.getExternalStorageTotalSpaceInGB.then((double _exTotal) => {
          if (_exTotal != null)
            {getInFree(_sdPaths, _selectedStorDir, _exFree, _exTotal)}
        });
  }

  void getExFree(List<String> _sdPaths, String _selectedStorDir) {
    StorageInfo.getExternalStorageFreeSpaceInGB.then((double _exFree) => {
          if (_exFree != null) {getExTotal(_sdPaths, _selectedStorDir, _exFree)}
        });
  }

  void getSelectedStorDir(List<Directory> _storageDirs) {
    List<String> _sdPaths = _storageDirs
        .map((Directory _dir) => _dir.path.substring(0, _dir.path.length - 5))
        .toList();
    getSelectedStorageDirectory().then((String _selectedStorDir) => {
          if (_sdPaths.contains(_selectedStorDir))
            {getExFree(_sdPaths, _selectedStorDir)}
        });
  }

  void getStorageDirectories() {
    getExternalStorageDirectories().then((List<Directory>? _storageDirs) => {
          if (_storageDirs != null) {getSelectedStorDir(_storageDirs)}
        });
  }

  void getStorageDirectory() {
    getExternalStorageDirectories().then((List<Directory>? _storageDirs) => {
          if (_storageDirs != null)
            {
              setState(() {
                storDirPaths = _storageDirs
                    .map((Directory _dir) =>
                        _dir.path.substring(0, _dir.path.length - 5))
                    .toList();
              })
            }
        });
  }

  void getInternalSpace() {
    StorageInfo.getStorageFreeSpaceInGB.then((double _inFree) => {
          if (_inFree != null)
            {
              StorageInfo.getStorageTotalSpaceInGB
                  .then((double _inTotal) => {
                        if (_inTotal != null)
                          {
                            setState(() {
                              _internalFree = _inFree;
                              _internalTotal = _inTotal;
                            })
                          }
                      })
                  .then((x) => {getStorageDirectory()})
            }
        });
  }

  @override
  void initState() {
    super.initState();
    multipleStorageDirs().then((bool x) => {
          if (x) {getStorageDirectories()} else {getInternalSpace()}
        });
  }
}
