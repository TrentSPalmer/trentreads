import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../database/data_classes.dart';
import '../database/database_helper.dart';

Future<List<ScrollableEpisode>> getEpisodeList(int feedID) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  if (await dbHelper.getNumEpisodes(feedID) == 0) {
    await fetchEpisodes(feedID);
  }
  return (await dbHelper.getScrollableEpisodeList(feedID));
}

Future<bool> fetchEpisodes(int _fid) async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final ScrollableFeed _feed = await dbHelper.getFeed(_fid);
  final http.Response response =
      await http.get(Uri.parse("http://${_feed.rssFeed}"));
  final List<DownloadableEpisode> insertableEpisodes = [];
  final List<ScrollableEpisode> updatableEpisodes = [];
  final List<DownloadedEpisode> downloadedEpisodes = [];
  if (response.statusCode == 200) {
    XmlDocument _rssData = XmlDocument.parse(response.body);
    XmlElement? _rss = _rssData.getElement('rss');
    if (_rss != null) {
      XmlElement? _channel = _rss.getElement('channel');
      if (_channel != null) {
        Iterable<XmlElement> _items = _channel.findElements('item');
        await Future.forEach(_items, (XmlElement _item) async {
          await addDownloadedEpisode(_item, downloadedEpisodes);
        });
      }
    }
  }
  await evaluateDownloadedEpisodes(dbHelper, _feed, updatableEpisodes,
      insertableEpisodes, downloadedEpisodes);
  if (updatableEpisodes.length > 0) {
    await dbHelper.batchUpdateEpisodes(updatableEpisodes);
  }
  if (insertableEpisodes.length > 0) {
    await dbHelper.batchInsertEpisodes(insertableEpisodes);
  }
  await dbHelper.markFeedUpdated(_fid);
  return ((insertableEpisodes.length > 0) || (updatableEpisodes.length > 0));
}

Future<int> getMP3FileSize(String _mp3Url) async {
  int _result = 0;
  final http.Response response = await http.head(Uri.parse(_mp3Url));
  if (response.statusCode == 200) {
    _result = int.parse(response.headers["content-length"] ?? "0");
  }
  return _result;
}

Future<void> addDownloadedEpisode(
    XmlElement _item, List<DownloadedEpisode> downloadedEpisodes) async {
  XmlElement? _title = _item.getElement('title');
  if (_title != null) {
    XmlElement? _desc = _item.getElement('description');
    if (_desc != null) {
      XmlElement? _enclosure = _item.getElement('enclosure');
      if (_enclosure != null) {
        String? _mp3Url = _enclosure.getAttribute('url');
        if (_mp3Url != null) {
          int _mp3Filesize = await getMP3FileSize(_mp3Url);
          if (_mp3Filesize != 0) {
            XmlElement? _image = _item.getElement('image');
            if (_image != null) {
              XmlElement? _url = _image.getElement("url");
              if (_url != null) {
                int _eImageFileSize = await getEpisodeImageFileSize(_url.text);
                if (_eImageFileSize != 0) {
                  downloadedEpisodes.add(DownloadedEpisode(
                    _title.text,
                    _mp3Url,
                    _mp3Url.substring(_mp3Url.indexOf('audio/mp3') + 10),
                    _mp3Filesize,
                    _url.text,
                    _url.text.substring(_url.text.indexOf("audio/images") + 13),
                    _eImageFileSize,
                    _desc.text,
                  ));
                }
              }
            }
          }
        }
      }
    }
  }
}

Future<int> getEpisodeImageFileSize(String _imageUrl) async {
  int _result = 0;
  final http.Response response = await http.head(Uri.parse(_imageUrl));
  if (response.statusCode == 200) {
    _result = int.parse(response.headers["content-length"] ?? "0");
  }
  return _result;
}

bool existingEpisodeNeedsUpdating(ScrollableEpisode x, DownloadedEpisode y) {
  return ((x.mp3Url != y.mp3Url) ||
      (x.mp3File != y.mp3File) ||
      (x.mp3FileSize != y.mp3Filesize) ||
      (x.imageUrl != y.imageUrl) ||
      (x.imageFileName != y.imageFileName) ||
      (x.imageFileSize != y.imageFileSize) ||
      (x.desc != y.desc));
}

Future<void> evaluateDownloadedEpisodes(
    DatabaseHelper dbHelper,
    ScrollableFeed _feed,
    List<ScrollableEpisode> updatableEpisodes,
    List<DownloadableEpisode> insertableEpisodes,
    List<DownloadedEpisode> downloadedEpisodes) async {
  await Future.forEach(downloadedEpisodes, (DownloadedEpisode y) async {
    if (await dbHelper.episodeExists(y.title, _feed.id)) {
      ScrollableEpisode existingEpisode =
          await dbHelper.getEpisode(y.title, _feed.id);
      if (existingEpisodeNeedsUpdating(existingEpisode, y)) {
        updatableEpisodes.add(ScrollableEpisode(
          existingEpisode.id,
          existingEpisode.title,
          existingEpisode.contributorID,
          existingEpisode.contributor,
          existingEpisode.feedID,
          existingEpisode.feed,
          y.mp3Url,
          y.mp3File,
          y.mp3Filesize,
          y.imageUrl,
          y.imageFileName,
          y.imageFileSize,
          y.desc,
        ));
      }
    } else {
      insertableEpisodes.add(DownloadableEpisode(
        y.title,
        _feed.contributorID,
        _feed.contributor,
        _feed.id,
        _feed.title,
        y.mp3Url,
        y.mp3File,
        y.mp3Filesize,
        y.imageUrl,
        y.imageFileName,
        y.imageFileSize,
        y.desc,
      ));
    }
  });
}
