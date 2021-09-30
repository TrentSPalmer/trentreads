import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../pref_utils.dart';

Future<List<MediaItem>> getQueue() async {
  int currentEpisode = await getCurrentEpisode();
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  List<MediaItem> result = await dbHelper.getMediaQueueFromDB(currentEpisode);
  return result;
}

Future<String> getCurrentMediaID() async {
  int currentEpisode = await getCurrentEpisode();
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  String result = await dbHelper.getMediaID(currentEpisode);
  return result;
}

Future<MediaItem> getCurrentMediaItem() async {
  int eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  MediaItem result = await dbHelper.getMediaItem(eid);
  return result;
}

Future<void> updateCurrentEpisode(String _eName, String _fName) async {
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  int _eid = await dbHelper.getEpisodeID(_fName, _eName);
  await setCurrentEpisode(_eid);
}

bool areMediaItemsEqual(MediaItem x, MediaItem y) {
  return (x.album == y.album && x.title == y.title);
}

bool areEqualQueues(List<MediaItem>? _x, List<MediaItem> y) {
  if (_x == null) {
    return false;
  } else {
    List<MediaItem> x = List<MediaItem>.from(_x.where((x) => x != null));
    if (x.length != y.length) return false;
    List<String> xTitles = x.map((e) => e.id).toList();
    List<String> yTitles = y.map((e) => e.id).toList();
    List<String> xAlbum = x.map((e) => e.album).toList();
    List<String> yAlbum = y.map((e) => e.album).toList();
    List<String> xID = x.map((e) => e.id).toList();
    List<String> yID = y.map((e) => e.id).toList();
    return (listEquals(xTitles, yTitles) &&
        listEquals(xAlbum, yAlbum) &&
        listEquals(xID, yID));
  }
}

Future<int> getPSeconds() async {
  int _eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  int result = await dbHelper.getPos(_eid);
  return result;
}

Future<int> getPSecondsFromNames(String _fName, String _eName) async {
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  int result = await dbHelper.getPosFromNames(_fName, _eName);
  return result;
}

Future<void> updatePSecondsByEid(int _pSeconds) async {
  int _eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  await dbHelper.updatePosByEid(_eid, _pSeconds);
}

Future<void> updatePSeconds(int _pSeconds, String _eName, String _fName) async {
  final DatabaseHelper dbHelper = await DatabaseHelper.instance;
  await dbHelper.updatePos(_eName, _fName, _pSeconds);
}
