import 'dart:convert';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../database/data_classes.dart';
import '../database/database_helper.dart';
import '../pref_utils.dart';

final String feedListApiUrl = "https://trentpalmer.org/feed-list-api/";

Future<List<ScrollableFeed>> getFeedList() async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  if (await dbHelper.getNumFeeds() == 0) {
    await fetchFeeds();
  }
  return (await dbHelper.getScrollableFeedList());
}

Future<List<String>> _getFeedImageFileUrlAndDesc(String _rssFeed) async {
  List<String> _result = [defaultImageUrl, '', ''];
  final http.Response _rssResponse =
      await http.get(Uri.parse("https://$_rssFeed"));
  if (_rssResponse.statusCode == 200) {
    XmlDocument _rssData = XmlDocument.parse(_rssResponse.body);
    XmlElement? _rss = _rssData.getElement('rss');
    if (_rss != null) {
      XmlElement? _channel = _rss.getElement("channel");
      if (_channel != null) {
        XmlElement? _desc = _channel.getElement("description");
        if (_desc != null) {
          XmlElement? _image = _channel.getElement("image");
          if (_image != null) {
            XmlElement? _url = _image.getElement("url");
            if (_url != null) {
              XmlElement? _imgDesc = _image.getElement("description");
              if (_imgDesc != null) {
                _result = [_url.text, _desc.text, _imgDesc.text];
              }
            }
          }
        }
      }
    }
  }
  return _result;
}

Future<int> getFeedImageFileSize(String _imageUrl) async {
  int _result = 0;
  final http.Response response = await http.head(Uri.parse(_imageUrl));
  if (response.statusCode == 200) {
    _result = int.parse(response.headers["content-length"] ?? "0");
  }
  return _result;
}

Future<bool> fetchFeeds() async {
  final _defaultShouldDownLoad = await globalGetShouldDownLoadDefault();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final http.Response response = await http.get(Uri.parse(feedListApiUrl));
  final List<DownloadableFeed> insertableFeeds = [];
  final List<ScrollableFeed> updatableFeeds = [];
  if (response.statusCode == 200) {
    final List<dynamic> responseBody = jsonDecode(response.body);
    final List<String> contributorNameList = [];
    final List<DownloadedFeed> downloadedFeeds = [];
    responseBody.forEach((x) {
      downloadedFeeds.add(DownloadedFeed(
        x["title"],
        x["read_by"],
        x["rss_feed"],
        '',
        '',
        0,
        '',
        '',
      ));
      if (!contributorNameList.contains(x['read_by'])) {
        contributorNameList.add(x['read_by']);
      }
    });
    await Future.forEach(downloadedFeeds, (DownloadedFeed x) async {
      List<String> _xImageUrlAndDesc =
          await _getFeedImageFileUrlAndDesc(x.rssFeed);
      x.imageUrl = _xImageUrlAndDesc[0];
      x.imageFileName =
          x.imageUrl.substring(x.imageUrl.indexOf("audio/images") + 13);
      x.imageFileSize = await getFeedImageFileSize(x.imageUrl);
      x.desc = _xImageUrlAndDesc[1];
      x.imageDesc = _xImageUrlAndDesc[2];
    });
    await updateContributors(contributorNameList);
    List<DownloadedFeed> validDownLoadedFeeds = downloadedFeeds
        .where((DownloadedFeed _d) => _d.imageFileSize > 0)
        .toList();
    await Future.forEach(validDownLoadedFeeds, (DownloadedFeed x) async {
      if (await dbHelper.feedExists(x.title, x.readBy)) {
        final ScrollableFeed existingFeed =
            await dbHelper.getExistingFeed(x.title, x.readBy);
        final DownloadedFeed newFeed = DownloadedFeed(
          x.title,
          x.readBy,
          x.rssFeed,
          x.imageUrl,
          x.imageFileName,
          x.imageFileSize,
          x.desc,
          x.imageDesc,
        );
        if (existingFeedNeedsUpdating(existingFeed, newFeed)) {
          final ScrollableFeed updatableFeed = ScrollableFeed(
            existingFeed.id,
            existingFeed.title,
            existingFeed.contributorID,
            existingFeed.contributor,
            newFeed.rssFeed,
            existingFeed.lastUpdate,
            existingFeed.link,
            newFeed.imageUrl,
            newFeed.imageFileName,
            newFeed.imageFileSize,
            existingFeed.shouldDownLoad,
            newFeed.desc,
            newFeed.imageDesc,
          );
          updatableFeeds.add(updatableFeed);
        }
      } else {
        final int _cid = await dbHelper.getContributorID(x.readBy);
        final DownloadableFeed insertableFeed = DownloadableFeed(
          x.title,
          _cid,
          x.readBy,
          x.rssFeed,
          0,
          '',
          x.imageUrl,
          x.imageFileName,
          x.imageFileSize,
          _defaultShouldDownLoad,
          x.desc,
          x.imageDesc,
        );
        insertableFeeds.add(insertableFeed);
      }
    });
  }
  if (updatableFeeds.length > 0) {
    await dbHelper.batchUpdateFeeds(updatableFeeds);
  }
  if (insertableFeeds.length > 0) {
    await dbHelper.batchInsertFeeds(insertableFeeds);
  }
  await markFeedsUpdated();
  return ((insertableFeeds.length > 0) || (updatableFeeds.length > 0));
}

bool existingFeedNeedsUpdating(ScrollableFeed x, DownloadedFeed y) {
  return (x.rssFeed != y.rssFeed ||
      x.imageUrl != y.imageUrl ||
      x.imageFileName != y.imageFileName ||
      x.imageFileSize != y.imageFileSize ||
      x.desc != y.desc ||
      x.imageDesc != y.imageDesc);
}

Future<void> updateContributors(List<String> contributorNameList) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final List<String> existingContributorList = await dbHelper.getContributors();
  await Future.forEach(existingContributorList, (String x) async {
    if (!contributorNameList.contains(x)) {
      await dbHelper.deleteContributor(x);
    }
  });
  await Future.forEach(contributorNameList, (String x) async {
    if (!existingContributorList.contains(x)) {
      await dbHelper.insertContributor(x);
    }
  });
}
