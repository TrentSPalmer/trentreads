import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../database/data_classes.dart';
import '../database/database_helper.dart';
import '../download/images.dart';
import '../feed_options/download_confirmation.dart';
import '../feed_options/util.dart';
import '../widgets.dart';

class FeedOptions extends StatefulWidget {
  final ScrollableFeed feed;

  FeedOptions({
    Key? key,
    required this.feed,
  }) : super(key: key);

  @override
  FeedOptionsState createState() => FeedOptionsState();
}

class FeedOptionsState extends State<FeedOptions> {
  int numEpisodes = 0;
  int numDownLoadedEpisodes = 0;
  bool shouldDownLoad = true;
  String _imageUrl = 'none';
  String _localImageFile = 'none';

  Future<void> getNumEpisodes() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.getNumEpisodes(widget.feed.id).then((int _numE) => {
          if (_numE != numEpisodes && mounted)
            {
              setState(() {
                numEpisodes = _numE;
              })
            }
        });
  }

  void deleteEpisodes() {
    deleteFeedEpisodes(widget.feed.id, true)
        .then((int x) => {getNumDownLoadedEps()});
  }

  void downLoadEpisodes() {
    downLoadFeedEpisode(widget.feed.id).then((int x) => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DownLoadConfirmation(
                        feedTitle: widget.feed.title,
                        numEpisodes: numEpisodes,
                        numNotDownloadedEpisodes:
                            numEpisodes - numDownLoadedEpisodes,
                      ))),
        });
  }

  Future<void> getNumDownLoadedEps() async {
    getNumDownLoadedEpisodes(widget.feed.id).then((int _numE) => {
          if (_numE != numDownLoadedEpisodes && mounted)
            {
              setState(() {
                numDownLoadedEpisodes = _numE;
              })
            }
        });
  }

  void toggleShouldDownLoad(bool shouldDL) {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper
        .markShouldDownLoadFeed(widget.feed.id, shouldDL)
        .then((bool _x) => {
              if (mounted)
                {
                  setState(() {
                    shouldDownLoad = shouldDL;
                  })
                }
            });
  }

  Future<void> getShouldDownLoad() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.shouldDownLoadFeed(widget.feed.id).then((bool _shouldDownLoad) => {
          if (_shouldDownLoad != shouldDownLoad && mounted)
            {
              setState(() {
                shouldDownLoad = _shouldDownLoad;
              })
            }
        });
  }

  Future<void> _launch(String url) async {
    if (await canLaunch(url)) await launch(url);
  }

  Future<void> _resetImageUrl() async {
    String _lFile = await getLocalImageFile(
      widget.feed.imageUrl,
      widget.feed.imageFileName,
      widget.feed.imageFileSize,
    );
    if (_lFile == 'none') {
      if (_imageUrl != widget.feed.imageUrl && mounted)
        setState(() {
          _imageUrl = widget.feed.imageUrl;
          _localImageFile = 'none';
        });
    } else {
      if (_localImageFile != _lFile && mounted)
        setState(() {
          _localImageFile = _lFile;
          _imageUrl = 'none';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feed.imageUrl.length > 0 &&
        _imageUrl == 'none' &&
        _localImageFile == 'none') {
      _resetImageUrl();
    }
    getNumEpisodes();
    getNumDownLoadedEps();
    getShouldDownLoad();
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text("Options: ${widget.feed.title}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(3.0),
              child: Container(
                decoration: myBoxDecoration(appColors.ivory),
                child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Column(
                    children: [
                      if (_localImageFile == 'none' && _imageUrl != 'none') ...[
                        Image.network(
                          _imageUrl,
                          key: Key('feed_network_image'),
                        ),
                      ],
                      if (_localImageFile != 'none' && _imageUrl == 'none') ...[
                        Image.file(
                          File(_localImageFile),
                          key: Key('feed_local_image'),
                        ),
                      ],
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        widget.feed.desc,
                        key: Key('feed_description'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Html(
                        key: Key('feed_image_description'),
                        data: widget.feed.imageDesc,
                        onLinkTap: (String? url,
                            RenderContext context,
                            Map<String, String> attributes,
                            dom.Element? element) {
                          if (url != null) _launch(url);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            infoTile(
              numEpisodes == 0
                  ? "There are no Episodes in the feed."
                  : "$numDownLoadedEpisodes of $numEpisodes episodes are downloaded to local storage.",
            ),
            if (numDownLoadedEpisodes > 0) ...[
              functionTile(
                  "Delete Episodes From Local Storage?", deleteEpisodes),
            ],
            if (numDownLoadedEpisodes < numEpisodes) ...[
              functionTile(
                "Download All Episodes for ${widget.feed.title} To Local Storage Immediately?",
                downLoadEpisodes,
              ),
            ],
            switchTile(
              "Enable Downloads to Local Storage for ${widget.feed.title} when/if you choose to listen to them?",
              shouldDownLoad,
              toggleShouldDownLoad,
            ),
          ],
        ),
      ),
    );
  }
}
