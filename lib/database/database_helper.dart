import 'package:audio_service/audio_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';
import '../download/episode_download.dart';
import 'data_classes.dart';

class DatabaseHelper {
  final String _databaseName = "app.db";
  final int _databaseVersion = 11;

  final String _contributorTable = "contributorTable";

  final String _contributorID = "id";
  final String _contributorName = "name";

  final String _feedTable = "feedTable";

  final String _feedID = "id";
  final String _feedTitle = "title";
  final String _feedContributorID = "contributorID";
  final String _rssFeed = "rssFeed";
  final String _lastUpdate = "lastUpdate";
  final String _link = "link";
  final String _feedImageUrl = "imageUrl";
  final String _feedImageFileName = "imageFileName";
  final String _feedImageFileSize = "imageFileSize";
  final String _feedShouldDownLoad = "shouldDownLoad";
  final String _feedDesc = "description";
  final String _feedImageDesc = "imageDescription";

  final String _episodeTable = "episodeTable";

  final String _episodeID = "id";
  final String _episodeTitle = "title";
  final String _episodeContributorID = "contributorID";
  final String _episodeFeedID = "feedID";
  final String _mp3Url = "mp3Url";
  final String _mp3File = "mp3File";
  final String _mp3FileSize = "mp3FileSize";
  final String _playPosition = "playPosition";
  final String _episodeImageUrl = "episodeImageUrl";
  final String _episodeImageFileName = "episodeImageFileName";
  final String _episodeImageFileSize = "episodeImageFileSize";
  final String _episodeDesc = "description";

  final String _dlQTable = "dlQTable";

  final String _dlQFileName = "fileName";
  final String _dlQnqTime = "dlNqTime";

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          '''ALTER TABLE $_episodeTable ADD COLUMN $_playPosition INT''');
    }
    if (oldVersion < 3) {
      await db.execute(
          '''ALTER TABLE $_feedTable ADD COLUMN $_feedImageUrl TEXT''');
      await db.execute(
          '''ALTER TABLE $_feedTable ADD COLUMN $_feedImageFileName TEXT''');
    }
    if (oldVersion < 4) {
      await db.execute(
          '''ALTER TABLE $_episodeTable ADD COLUMN $_episodeImageUrl TEXT''');
      await db.execute(
          '''ALTER TABLE $_episodeTable ADD COLUMN $_episodeImageFileName TEXT''');
    }
    if (oldVersion < 5) {
      await db.execute(
          '''ALTER TABLE $_feedTable ADD COLUMN $_feedImageFileSize INT''');
    }
    if (oldVersion < 6) {
      await db.execute(
          '''ALTER TABLE $_episodeTable ADD COLUMN $_episodeImageFileSize INT''');
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE $_dlQTable ($_dlQFileName TEXT, $_dlQnqTime INT)''');
    }
    if (oldVersion < 8) {
      await db.execute(
          '''ALTER TABLE $_feedTable ADD COLUMN $_feedShouldDownLoad INT''');
    }
    if (oldVersion < 9) {
      await db
          .execute('''ALTER TABLE $_feedTable ADD COLUMN $_feedDesc TEXT''');
    }
    if (oldVersion < 10) {
      await db.execute(
          '''ALTER TABLE $_episodeTable ADD COLUMN $_episodeDesc TEXT''');
    }
    if (oldVersion < 11) {
      await db.execute(
          '''ALTER TABLE $_feedTable ADD COLUMN $_feedImageDesc TEXT''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $_contributorTable (
            $_contributorID INTEGER PRIMARY KEY AUTOINCREMENT,
            $_contributorName TEXT
        )
        ''');
    await db.execute('''
        CREATE TABLE $_feedTable (
            $_feedID INTEGER PRIMARY KEY AUTOINCREMENT,
            $_feedTitle TEXT,
            $_feedContributorID INT,
            $_rssFeed TEXT,
            $_lastUpdate INT,
            $_link TEXT,
            $_feedImageUrl TEXT,
            $_feedImageFileName TEXT,
            $_feedImageFileSize INT,
            $_feedShouldDownLoad INT,
            $_feedDesc TEXT,
            $_feedImageDesc TEXT
        )
        ''');
    await db.execute('''
        CREATE TABLE $_episodeTable (
            $_episodeID INTEGER PRIMARY KEY AUTOINCREMENT,
            $_episodeTitle TEXT,
            $_episodeContributorID INT,
            $_episodeFeedID INT,
            $_mp3Url TEXT,
            $_mp3File TEXT,
            $_mp3FileSize INT,
            $_playPosition INT,
            $_episodeImageUrl TEXT,
            $_episodeImageFileName TEXT,
            $_episodeImageFileSize INT,
            $_episodeDesc TEXT
        )
        ''');
    await db.execute('''
        CREATE TABLE $_dlQTable (
            $_dlQFileName TEXT,
            $_dlQnqTime INT 
        )
        ''');
  }

  Future<bool> inFileDownloadQueue(String _file) async {
    Database db = await instance.database;
    int _currentTime = DateTime.now().millisecondsSinceEpoch ~/ 10000;
    await db.delete(
      _dlQTable,
      where: '$_dlQnqTime < ?',
      whereArgs: [_currentTime - 7200],
    );
    List<Map> _countQuery = await db.rawQuery(
        'SELECT COUNT() FROM $_dlQTable WHERE $_dlQFileName = ?', [_file]);
    bool _result = _countQuery[0]['COUNT()'] > 0;
    if (!_result) {
      await db.rawInsert(
          "INSERT INTO $_dlQTable($_dlQFileName, $_dlQnqTime) VALUES(?,?)",
          [_file, _currentTime]);
    }
    return _result;
  }

  Future<void> cleanUpFileDownLoadQueue(String _file) async {
    Database db = await instance.database;
    await db.delete(
      _dlQTable,
      where: '$_dlQFileName = ?',
      whereArgs: [_file],
    );
  }

  Future<MediaItem> getMediaItem(int eid) async {
    int _fid = await getEpisodeFeedID(eid);
    String _fName = await getFeedName(_fid);
    String _eName = await getEpisodeTitle(eid);
    String _mp3 = await getMediaID(eid);
    return MediaItem(id: _mp3, album: _fName, title: _eName);
  }

  Future<List<MediaItem>> getMediaQueueFromDB(int eid) async {
    int _fid = await getEpisodeFeedID(eid);
    String _fName = await getFeedName(_fid);
    Database db = await instance.database;
    List<MediaItem> _result = [];
    List<IntermediateMediaItemQueryResult> _intermediate = [];
    List<Map> _queryResult = await db.query(
      _episodeTable,
      columns: [
        _mp3Url,
        _episodeTitle,
        _mp3File,
        _mp3FileSize,
      ],
      where: '$_episodeFeedID = ?',
      whereArgs: [_fid],
    );
    _queryResult.forEach((x) {
      _intermediate.add(IntermediateMediaItemQueryResult(
        mp3Url: x[_mp3Url],
        mp3File: x[_mp3File],
        mp3FileSize: x[_mp3FileSize],
        album: _fName,
        title: x[_episodeTitle],
      ));
    });
    bool _shouldDownLoad = await shouldDownLoadFeed(_fid);
    await Future.forEach(_intermediate,
        (IntermediateMediaItemQueryResult x) async {
      _result.add(MediaItem(
        id: await getEpisodeMP3(
          x.mp3Url,
          x.mp3File,
          x.mp3FileSize,
          _shouldDownLoad,
          _fid,
          true,
        ),
        album: x.album,
        title: x.title,
      ));
    });
    return _result;
  }

  Future<bool> markAllFeedsShouldDownLoad(bool _shouldDownLoad) async {
    Database db = await instance.database;
    await db.update(
      _feedTable,
      {_feedShouldDownLoad: (_shouldDownLoad) ? 1 : 0},
    );
    return true;
  }

  Future<bool> markShouldDownLoadFeed(int _fid, bool _shouldDownLoad) async {
    Database db = await instance.database;
    await db.update(
      _feedTable,
      {_feedShouldDownLoad: (_shouldDownLoad) ? 1 : 0},
      where: "$_feedID = ?",
      whereArgs: [_fid],
    );
    return true;
  }

  Future<bool> shouldDownLoadFeed(int _fid) async {
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _feedTable,
      columns: [_feedShouldDownLoad],
      where: "$_feedID = ?",
      whereArgs: [_fid],
    );
    return _queryResult[0][_feedShouldDownLoad] == null
        ? true
        : _queryResult[0][_feedShouldDownLoad] == 1;
  }

  Future<String> getMediaID(int eid) async {
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _episodeTable,
      columns: [_mp3Url, _mp3File, _mp3FileSize, _episodeFeedID],
      where: '$_episodeID = ?',
      whereArgs: [eid],
    );
    bool _shouldDownLoad =
        await shouldDownLoadFeed(_queryResult[0][_episodeFeedID]);
    String _result = await getEpisodeMP3(
      _queryResult[0][_mp3Url],
      _queryResult[0][_mp3File],
      _queryResult[0][_mp3FileSize],
      _shouldDownLoad,
      _queryResult[0][_episodeFeedID],
      true,
    );
    return _result;
  }

  Future<String> getFeedName(int fid) async {
    Database db = await instance.database;
    List<Map> _fName = await db.query(
      _feedTable,
      columns: [_feedTitle],
      where: '$_feedID = ?',
      whereArgs: [fid],
    );
    return _fName[0][_feedTitle];
  }

  Future<int> getEpisodeFeedID(int eid) async {
    Database db = await instance.database;
    List<Map> _fid = await db.query(
      _episodeTable,
      columns: [_episodeFeedID],
      where: '$_episodeID = ?',
      whereArgs: [eid],
    );
    return _fid[0][_episodeFeedID];
  }

  Future<void> updatePos(String _eName, String _fName, _pSeconds) async {
    int _fid = await getFeedID(_fName);
    Database db = await instance.database;
    await db.update(
      _episodeTable,
      {
        _playPosition: _pSeconds,
      },
      where: '$_episodeTitle = ? AND $_episodeFeedID = ?',
      whereArgs: [_eName, _fid],
    );
  }

  Future<void> updatePosByEid(int _eid, int _pSeconds) async {
    Database db = await instance.database;
    await db.update(
      _episodeTable,
      {
        _playPosition: _pSeconds,
      },
      where: '$_episodeID = ?',
      whereArgs: [_eid],
    );
  }

  Future<int> getPosFromNames(String _fName, String _eName) async {
    int _fid = await getFeedID(_fName);
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _episodeTable,
      columns: [_playPosition],
      where: '$_episodeTitle = ? AND $_episodeFeedID = ?',
      whereArgs: [_eName, _fid],
    );
    return _queryResult[0][_playPosition] ?? 0;
  }

  Future<int> getPos(int _eid) async {
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _episodeTable,
      columns: [_playPosition],
      where: '$_episodeID = ?',
      whereArgs: [_eid],
    );
    return _queryResult[0][_playPosition] ?? 0;
  }

  Future<String> getEpisodeTitle(int eid) async {
    Database db = await instance.database;
    List<Map> _eName = await db.query(
      _episodeTable,
      columns: [_episodeTitle],
      where: '$_episodeID = ?',
      whereArgs: [eid],
    );
    return _eName[0][_episodeTitle];
  }

  Future<void> markFeedUpdated(int _fid) async {
    int _currentTime = DateTime.now().millisecondsSinceEpoch ~/ 10000;
    Database db = await instance.database;
    await db.update(
      _feedTable,
      {
        _lastUpdate: _currentTime,
      },
      where: '$_feedID = ?',
      whereArgs: [_fid],
    );
  }

  Future<void> batchUpdateEpisodes(List<ScrollableEpisode> episodeList) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    episodeList.forEach((ScrollableEpisode x) => {
          batch.update(
            _episodeTable,
            {
              _episodeTitle: x.title,
              _episodeContributorID: x.contributorID,
              _episodeFeedID: x.feedID,
              _mp3Url: x.mp3Url,
              _mp3File: x.mp3File,
              _mp3FileSize: x.mp3FileSize,
              _episodeImageUrl: x.imageUrl,
              _episodeImageFileName: x.imageFileName,
              _episodeImageFileSize: x.imageFileSize,
              _episodeDesc: x.desc,
            },
            where: '$_episodeID = ?',
            whereArgs: [x.id],
          )
        });
    await batch.commit(noResult: true);
  }

  Future<void> batchUpdateFeeds(List<ScrollableFeed> feedList) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    feedList.forEach((ScrollableFeed x) => {
          batch.update(
            _feedTable,
            {
              _feedTitle: x.title,
              _feedContributorID: x.contributorID,
              _rssFeed: x.rssFeed,
              _lastUpdate: x.lastUpdate,
              _link: x.link,
              _feedImageUrl: x.imageUrl,
              _feedImageFileName: x.imageFileName,
              _feedImageFileSize: x.imageFileSize,
              _feedShouldDownLoad: (x.shouldDownLoad) ? 1 : 0,
              _feedDesc: x.desc,
              _feedImageDesc: x.imageDesc,
            },
            where: '$_feedID = ?',
            whereArgs: [x.id],
          )
        });
    await batch.commit(noResult: true);
  }

  Future<void> batchInsertEpisodes(
      List<DownloadableEpisode> episodeList) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    episodeList.forEach((DownloadableEpisode x) => {
          batch.insert(_episodeTable, {
            _episodeTitle: x.title,
            _episodeContributorID: x.contributorID,
            _episodeFeedID: x.feedID,
            _mp3Url: x.mp3Url,
            _mp3File: x.mp3File,
            _mp3FileSize: x.mp3FileSize,
            _episodeImageUrl: x.imageUrl,
            _episodeImageFileName: x.imageFileName,
            _episodeImageFileSize: x.imageFileSize,
            _episodeDesc: x.desc,
          })
        });
    await batch.commit(noResult: true);
  }

  Future<void> batchInsertFeeds(List<DownloadableFeed> feedList) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    feedList.forEach((DownloadableFeed x) => {
          batch.insert(_feedTable, {
            _feedTitle: x.title,
            _feedContributorID: x.contributorID,
            _rssFeed: x.rssFeed,
            _lastUpdate: x.lastUpdate,
            _link: x.link,
            _feedImageUrl: x.imageUrl,
            _feedImageFileName: x.imageFileName,
            _feedImageFileSize: x.imageFileSize,
            _feedShouldDownLoad: (x.shouldDownLoad) ? 1 : 0,
            _feedDesc: x.desc,
            _feedImageDesc: x.imageDesc,
          })
        });
    await batch.commit(noResult: true);
  }

  Future<ScrollableFeed> getExistingFeed(String title, String readBy) async {
    final int _cid = await getContributorID(readBy);
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _feedTable,
      where: '$_feedTitle = ? AND $_feedContributorID = ?',
      whereArgs: [title, _cid],
    );
    String _cName =
        await getContributorName(_queryResult[0][_feedContributorID]);
    return ScrollableFeed(
      _queryResult[0][_feedID],
      _queryResult[0][_feedTitle],
      _queryResult[0][_feedContributorID],
      _cName,
      _queryResult[0][_rssFeed],
      _queryResult[0][_lastUpdate],
      _queryResult[0][_link],
      _queryResult[0][_feedImageUrl] ?? defaultImageUrl,
      _queryResult[0][_feedImageFileName] ?? defaultImageFileName,
      _queryResult[0][_feedImageFileSize] ?? 0,
      _queryResult[0][_feedShouldDownLoad] == null
          ? true
          : _queryResult[0][_feedShouldDownLoad] == 1,
      _queryResult[0][_feedDesc] ?? '',
      _queryResult[0][_feedImageDesc] ?? '',
    );
  }

  Future<ScrollableFeed> getFeed(int fid) async {
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _feedTable,
      where: '$_feedID = ?',
      whereArgs: [fid],
    );
    String _cName =
        await getContributorName(_queryResult[0][_feedContributorID]);
    return ScrollableFeed(
      _queryResult[0][_feedID],
      _queryResult[0][_feedTitle],
      _queryResult[0][_feedContributorID],
      _cName,
      _queryResult[0][_rssFeed],
      _queryResult[0][_lastUpdate],
      _queryResult[0][_link],
      _queryResult[0][_feedImageUrl] ?? defaultImageUrl,
      _queryResult[0][_feedImageFileName] ?? defaultImageFileName,
      _queryResult[0][_feedImageFileSize] ?? 0,
      _queryResult[0][_feedShouldDownLoad] == null
          ? true
          : _queryResult[0][_feedShouldDownLoad] == 1,
      _queryResult[0][_feedDesc] ?? '',
      _queryResult[0][_feedImageDesc] ?? '',
    );
  }

  Future<List<ScrollableFeed>> getScrollableFeedList() async {
    List<ScrollableFeed> result = [];
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _feedTable,
      columns: [
        _feedID,
        _feedTitle,
        _feedContributorID,
        _rssFeed,
        _lastUpdate,
        _link,
        _feedImageUrl,
        _feedImageFileName,
        _feedImageFileSize,
        _feedShouldDownLoad,
        _feedDesc,
        _feedImageDesc,
      ],
    );
    _queryResult.forEach((x) {
      result.add(ScrollableFeed(
        x[_feedID],
        x[_feedTitle],
        x[_feedContributorID],
        '',
        x[_rssFeed],
        x[_lastUpdate],
        x[_link],
        x[_feedImageUrl] ?? defaultImageUrl,
        x[_feedImageFileName] ?? defaultImageFileName,
        x[_feedImageFileSize] ?? 0,
        x[_feedShouldDownLoad] == null ? true : x[_feedShouldDownLoad] == 1,
        x[_feedDesc] ?? '',
        x[_feedImageDesc] ?? '',
      ));
    });
    await Future.forEach(result, (ScrollableFeed x) async {
      String _cName = await getContributorName(x.contributorID);
      x.contributor = _cName;
    });
    return result;
  }

  Future<int> getFeedLastUpdate(int _fid) async {
    Database db = await instance.database;
    List<Map> _result = await db.query(
      _feedTable,
      columns: [_lastUpdate],
      where: '$_feedID = ?',
      whereArgs: [_fid],
    );
    return _result[0][_lastUpdate];
  }

  Future<int> getFeedID(String _fName) async {
    Database db = await instance.database;
    List<Map> _result = await db.query(
      _feedTable,
      columns: [_feedID],
      where: '$_feedTitle = ?',
      whereArgs: [_fName],
    );
    return _result[0][_feedID];
  }

  Future<int> getEpisodeID(String _fName, String _eName) async {
    int _fid = await getFeedID(_fName);
    Database db = await instance.database;
    List<Map> _result = await db.query(
      _episodeTable,
      columns: [_episodeID],
      where: '$_episodeFeedID = ? AND $_episodeTitle = ?',
      whereArgs: [_fid, _eName],
    );
    return _result[0][_episodeID];
  }

  Future<int> getContributorID(String name) async {
    Database db = await instance.database;
    List<Map> _cid = await db.query(
      _contributorTable,
      columns: [_contributorID],
      where: '$_contributorName = ?',
      whereArgs: [name],
    );
    return _cid[0][_contributorID];
  }

  Future<String> deleteFeed(int _feedNo) async {
    Database db = await instance.database;
    List<Map> _title = await db.query(_feedTable,
        columns: [_feedTitle], where: '$_feedID = ?', whereArgs: [_feedNo]);
    await db.delete(_feedTable, where: '$_feedID = ?', whereArgs: [_feedNo]);
    return _title[0][_feedTitle];
  }

  Future<bool> feedExists(String title, String readBy) async {
    final int _cid = await getContributorID(readBy);
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT COUNT() FROM $_feedTable WHERE $_feedTitle = ? AND $_feedContributorID = ?',
        [title, _cid]);
    return result[0]['COUNT()'] > 0;
  }

  Future<bool> episodeExists(String title, int _fid) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT COUNT() FROM $_episodeTable WHERE $_episodeTitle = ? AND $_episodeFeedID = ?',
        [title, _fid]);
    return result[0]['COUNT()'] > 0;
  }

  Future<int> getNumFeeds() async {
    Database db = await instance.database;
    List<Map> _result = await db.rawQuery('SELECT COUNT() FROM $_feedTable');
    return _result[0]['COUNT()'];
  }

  Future<int> getNumDownLoadEnabledFeeds() async {
    Database db = await instance.database;
    List<Map> _result = await db.rawQuery(
        'SELECT COUNT() FROM $_feedTable WHERE $_feedShouldDownLoad = 1');
    return _result[0]['COUNT()'];
  }

  Future<bool> downLoadEnabledForAllFeeds() async {
    int _numFeeds = await getNumFeeds();
    int _numDownLoadEnabledFeeds = await getNumDownLoadEnabledFeeds();
    return _numFeeds == _numDownLoadEnabledFeeds;
  }

  Future<int> getNumEpisodes(int _fid) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT COUNT() FROM $_episodeTable WHERE $_episodeFeedID = ?', [_fid]);
    return result[0]['COUNT()'];
  }

  Future<String> getNthMP3(int _offset) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        "SELECT $_mp3File FROM $_episodeTable LIMIT 1 OFFSET $_offset");
    return result[0][_mp3File];
  }

  Future<int> getNthFeed(int _offset) async {
    Database db = await instance.database;
    List<Map> result = await db
        .rawQuery("SELECT $_feedID FROM $_feedTable LIMIT 1 OFFSET $_offset");
    return result[0][_feedID];
  }

  Future<int> getGlobalNumEpisodes() async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT COUNT() FROM $_episodeTable');
    return result[0]['COUNT()'];
  }

  Future<void> insertContributor(String contributor) async {
    Database db = await instance.database;
    await db.rawInsert(
        "INSERT INTO $_contributorTable($_contributorName) VALUES(?)",
        [contributor]);
  }

  Future<int> getMP3Size(String _mp3) async {
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _episodeTable,
      columns: [_mp3FileSize],
      where: "$_mp3File = ?",
      whereArgs: [_mp3],
    );
    return _queryResult[0][_mp3FileSize];
  }

  Future<List<ScrollableEpisode>> getScrollableEpisodeList(int feedNo) async {
    List<ScrollableEpisode> result = [];
    Database db = await instance.database;
    String _fName = await getFeedName(feedNo);
    List<Map> _queryResult = await db.query(
      _episodeTable,
      columns: [
        _episodeID,
        _episodeTitle,
        _episodeContributorID,
        _episodeFeedID,
        _mp3Url,
        _mp3File,
        _mp3FileSize,
        _episodeImageUrl,
        _episodeImageFileName,
        _episodeImageFileSize,
        _episodeDesc,
      ],
      where: '$_episodeFeedID = ?',
      whereArgs: [feedNo],
    );
    _queryResult.forEach((x) {
      result.add(ScrollableEpisode(
        x[_episodeID],
        x[_episodeTitle],
        x[_episodeContributorID],
        '',
        x[_episodeFeedID],
        _fName,
        x[_mp3Url],
        x[_mp3File],
        x[_mp3FileSize],
        x[_episodeImageUrl] ?? defaultImageUrl,
        x[_episodeImageFileName] ?? defaultImageFileName,
        x[_episodeImageFileSize] ?? 0,
        x[_episodeDesc] ?? '',
      ));
    });
    await Future.forEach(result, (ScrollableEpisode x) async {
      String _cName = await getContributorName(x.contributorID);
      x.contributor = _cName;
    });
    return result;
  }

  Future<String> getContributorName(int cid) async {
    Database db = await instance.database;
    List<Map> _cName = await db.query(
      _contributorTable,
      columns: [_contributorName],
      where: '$_contributorID = ?',
      whereArgs: [cid],
    );
    return _cName[0][_contributorName];
  }

  Future<ScrollableEpisode> getEpisode(String _eTitle, int _fid) async {
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(_episodeTable,
        where: '$_episodeTitle = ? AND $_episodeFeedID = ?',
        whereArgs: [_eTitle, _fid]);
    String _cName =
        await getContributorName(_queryResult[0][_episodeContributorID]);
    String _fName = await getFeedName(_queryResult[0][_episodeFeedID]);
    return ScrollableEpisode(
      _queryResult[0][_episodeID],
      _queryResult[0][_episodeTitle],
      _queryResult[0][_episodeContributorID],
      _cName,
      _queryResult[0][_episodeFeedID],
      _fName,
      _queryResult[0][_mp3Url],
      _queryResult[0][_mp3File],
      _queryResult[0][_mp3FileSize],
      _queryResult[0][_episodeImageUrl] ?? defaultImageUrl,
      _queryResult[0][_episodeImageFileName] ?? defaultImageFileName,
      _queryResult[0][_episodeImageFileSize] ?? 0,
      _queryResult[0][_episodeDesc] ?? '',
    );
  }

  Future<void> deleteContributor(String contributor) async {
    Database db = await instance.database;
    await db.delete(_contributorTable,
        where: '$_contributorName = ?', whereArgs: [contributor]);
  }

  Future<List<String>> getContributors() async {
    List<String> result = [];
    Database db = await instance.database;
    List<Map> _queryResult = await db.query(
      _contributorTable,
      columns: [_contributorName],
    );
    if (_queryResult.length > 0) {
      _queryResult.forEach((x) => {result.add(x['name'])});
    }
    return result;
  }
}
