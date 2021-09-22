import 'package:shared_preferences/shared_preferences.dart';
import 'database/database_helper.dart';
import 'constants.dart';

Future<void> markFeedsUpdated() async {
  int _currentTime = DateTime.now().millisecondsSinceEpoch ~/ 10000;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt("feedsLastUpdatedAt", _currentTime);
}

Future<bool> lastFeedsUpdateExpired() async {
  int _currentTime = DateTime.now().millisecondsSinceEpoch ~/ 10000;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  int _feedsLastUpdatedAt = prefs.getInt("feedsLastUpdatedAt") ?? 0;
  return ((_currentTime - _feedsLastUpdatedAt) > updateInterval);
}

Future<bool> lastFeedUpdateExpired(int _fid) async {
  int _currentTime = DateTime.now().millisecondsSinceEpoch ~/ 10000;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  int _feedLastUpdate = await dbHelper.getFeedLastUpdate(_fid);
  return ((_currentTime - _feedLastUpdate) > updateInterval);
}

String getHumanReadableDuration(Duration _d) {
  int _totalSeconds =  _d.inSeconds.round();
  int _seconds = _totalSeconds % 60;
  String _secondsString = (_seconds < 10) ? "0${_seconds}" : _seconds.toString();
  if (_totalSeconds < 60) return "00:${_secondsString}";

  int _totalMinutes = ((_totalSeconds - _seconds) / 60).round();
  int _minutes = _totalMinutes % 60;
  String _minutesString = (_minutes < 10) ? "0${_minutes}" : _minutes.toString();
  if (_totalMinutes < 60) return "$_minutesString:${_secondsString}";

  int _hours = ((_totalMinutes - _minutes) / 60).round();
  return "${_hours}:${_minutesString}:${_secondsString}";
}

Future<int> getCurrentEpisode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  int result = prefs.getInt("CurrentEpisode") ?? -1;
  return result;
}

Future<void> setStoragePref(String _path) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("SelectedStorageDevice", _path);
}

Future<int> globalSetShouldDownLoadDefault(bool _should) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("GlobalShouldDownLoadDefault", _should);
  return 1;
}

Future<bool> globalGetShouldDownLoadDefault() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  bool _result = await prefs.getBool("GlobalShouldDownLoadDefault") ?? true;
  return _result;
}

Future<bool> getMobileDownLoadOK() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  bool _result = await prefs.getBool("MobileDownLoadOK") ?? true;
  return _result;
}

Future<int> setMobileDownLoadOK(bool _should) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("MobileDownLoadOK", _should);
  return 1;
}

Future<String> getCurrentFeedTitle() async {
  int eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  int fid = await dbHelper.getEpisodeFeedID(eid);
  String _fName = await dbHelper.getFeedName(fid);
  return _fName;
}

Future<int> getCurrentFeedID() async {
  int eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  int fid = await dbHelper.getEpisodeFeedID(eid);
  return fid;
}

Future<String> getCurrentEpisodeTitle() async {
  int eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  String _eName = await dbHelper.getEpisodeTitle(eid);
  return _eName;
}

Future<void> setNewPlayPosition(_pSec) async {
  int eid = await getCurrentEpisode();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  await dbHelper.updatePosByEid(eid, _pSec);
}

Future<void> setCurrentEpisodeByName(String _eTitle) async {
  String _fTitle = await getCurrentFeedTitle();
  await setNewCurrentEpisode(_fTitle, _eTitle);
}

Future<void> setCurrentEpisode(int eid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("CurrentEpisode", eid);
}

Future<void> setNewCurrentEpisode(String feed, String episode) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  int _eid = await dbHelper.getEpisodeID(feed, episode);
  await setCurrentEpisode(_eid);
}