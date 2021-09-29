import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../pref_utils.dart';
import '../widgets.dart';
import 'util.dart';
import '../constants.dart';

class GlobalDownLoadSettings extends StatefulWidget {
  @override
  GlobalDownLoadSettingsState createState() => GlobalDownLoadSettingsState();
}

class GlobalDownLoadSettingsState extends State<GlobalDownLoadSettings> {
  int numFeeds = 0;
  int numDownLoadEnabledFeeds = 0;
  int numDownLoadedEpisodes = 0;
  bool globalShouldDownLoad = true;
  bool allFeedsShouldDownLoad = true;

  Future<void> getAllFeedsShouldDownLoad() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.downLoadEnabledForAllFeeds().then((bool _shouldDL) => {
          if (_shouldDL != allFeedsShouldDownLoad && mounted)
            {
              setState(() {
                allFeedsShouldDownLoad = _shouldDL;
              })
            }
        });
  }

  void markAllFeedsShouldDownLoad(bool shouldDL) {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.markAllFeedsShouldDownLoad(shouldDL).then((bool x) => {
          if (mounted)
            setState(() {
              allFeedsShouldDownLoad = shouldDL;
            })
        });
  }

  Future<void> getNumDownLoadedEps() async {
    getGlobalNumDownLoadedEpisodes().then((int _numE) => {
          if (_numE != numDownLoadedEpisodes && mounted)
            {
              setState(() {
                numDownLoadedEpisodes = _numE;
              })
            }
        });
  }

  void toggleGlobalShouldDownLoad(bool shouldDL) {
    globalSetShouldDownLoadDefault(shouldDL).then((int x) => {
          if (mounted)
            setState(() {
              globalShouldDownLoad = shouldDL;
            })
        });
  }

  Future<void> getGlobalShouldDownLoadDefault() async {
    globalGetShouldDownLoadDefault().then((bool _globalShouldDownLoad) => {
          if (_globalShouldDownLoad != globalShouldDownLoad && mounted)
            {
              setState(() {
                globalShouldDownLoad = _globalShouldDownLoad;
              })
            }
        });
  }

  Future<void> getNumDownLoadEnabledFeeds() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.getNumDownLoadEnabledFeeds().then((int _numFeeds) => {
          if (_numFeeds != numDownLoadEnabledFeeds && mounted)
            setState(() {
              numDownLoadEnabledFeeds = _numFeeds;
            })
        });
  }

  Future<void> getNumFeeds() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.getNumFeeds().then((int _numFeeds) => {
          if (_numFeeds != numFeeds && mounted)
            setState(() {
              numFeeds = _numFeeds;
            })
        });
  }

  void deleteEpisodes() {
    deleteAllEpisodes().then((int x) => {getNumDownLoadedEps()});
  }

  @override
  Widget build(BuildContext context) {
    getNumDownLoadedEps();
    getNumDownLoadEnabledFeeds();
    getGlobalShouldDownLoadDefault();
    getAllFeedsShouldDownLoad();
    getNumFeeds();
    String gedlX =
        "Enable Downloads to Local Storage For All Feeds Specifically?";
    String gedlY =
        " ($numDownLoadEnabledFeeds of $numFeeds feeds are currently enabled)";
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('Global Download Settings'),
      ),
      body: Column(
        children: [
          infoTile(
              "$numDownLoadedEpisodes episodes are downloaded to local storage."),
          switchTile(
            "Enable Downloads to Local Storage by Default?",
            globalShouldDownLoad,
            toggleGlobalShouldDownLoad,
          ),
          if (numDownLoadedEpisodes > 0) ...[
            functionTile(
                "Delete All Episodes From Local Storage?", deleteEpisodes),
          ],
          switchTile(
            "$gedlX$gedlY",
            allFeedsShouldDownLoad,
            markAllFeedsShouldDownLoad,
          ),
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
}
