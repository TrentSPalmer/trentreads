import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../feed_options/download_confirmation.dart';
import '../feed_options/util.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/database_helper.dart';
import '../constants.dart';
import '../widgets.dart';

class FeedOptions extends StatefulWidget {
  final String feedTitle;
  final String feedDesc;
  final int feedID;
  final String feedImageDesc;

  FeedOptions({
    Key? key,
    required this.feedTitle,
    required this.feedDesc,
    required this.feedID,
    required this.feedImageDesc,
  }) : super(key: key);

  @override
  FeedOptionsState createState() => FeedOptionsState();
}

class FeedOptionsState extends State<FeedOptions> {
  int numEpisodes = 0;
  int numDownLoadedEpisodes = 0;
  bool shouldDownLoad = true;

  Future<void> getNumEpisodes() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    dbHelper.getNumEpisodes(widget.feedID).then((int _numE) => {
          if (_numE != numEpisodes && mounted)
            {
              setState(() {
                numEpisodes = _numE;
              })
            }
        });
  }

  void deleteEpisodes() {
    deleteFeedEpisodes(widget.feedID, true)
        .then((int x) => {getNumDownLoadedEps()});
  }

  void downLoadEpisodes() {
    downLoadFeedEpisode(widget.feedID).then((int x) => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DownLoadConfirmation(
                        feedTitle: widget.feedTitle,
                        numEpisodes: numEpisodes,
                        numNotDownloadedEpisodes:
                            numEpisodes - numDownLoadedEpisodes,
                      ))),
        });
  }

  Future<void> getNumDownLoadedEps() async {
    getNumDownLoadedEpisodes(widget.feedID).then((int _numE) => {
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
    dbHelper.markShouldDownLoadFeed(widget.feedID, shouldDL).then((bool _x) => {
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
    dbHelper.shouldDownLoadFeed(widget.feedID).then((bool _shouldDownLoad) => {
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

  @override
  Widget build(BuildContext context) {
    getNumEpisodes();
    getNumDownLoadedEps();
    getShouldDownLoad();
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text("Options: ${widget.feedTitle}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Container(
              decoration: myBoxDecoration(appColors.ivory),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    Text(
                      widget.feedDesc,
                      key: Key('feed_description_title'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Html(
                        data: widget.feedImageDesc,
                        onLinkTap: (String? url,
                            RenderContext context,
                            Map<String, String> attributes,
                            dom.Element? element) {
                          if (url != null) _launch(url);
                        }),
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
            functionTile("Delete Episodes From Local Storage?", deleteEpisodes),
          ],
          if (numDownLoadedEpisodes < numEpisodes) ...[
            functionTile(
              "Download All Episodes for ${widget.feedTitle} To Local Storage Immediately?",
              downLoadEpisodes,
            ),
            switchTile(
              "Enable Downloads to Local Storage for ${widget.feedTitle} when/if you choose to listen to them?",
              shouldDownLoad,
              toggleShouldDownLoad,
            ),
          ],
        ],
      ),
    );
  }
}
