import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../database/data_classes.dart';
import '../download/images.dart';

String getHtml(String desc) {
  int _indA = desc.indexOf('<p>');
  String _A = desc.substring(_indA);
  int _indB = _A.substring(3).indexOf('<p>') + 3;
  String _summary = _A.substring(0, _indB);
  String _B = _A.substring(_indB);
  int _indC = _B.substring(3).indexOf('<p>') + 3;
  String _C = _B.substring(_indC);
  return "$_summary$_C";
}

class EpisodeItemDesc extends StatefulWidget {
  final ScrollableEpisode episode;

  EpisodeItemDesc({
    Key? key,
    required this.episode,
  }) : super(key: key);

  @override
  EpisodeItemDescState createState() => EpisodeItemDescState();
}

class EpisodeItemDescState extends State<EpisodeItemDesc> {
  String _imageUrl = 'none';
  String _localImageFile = 'none';

  Future<void> _resetImageUrl() async {
    String _lFile = await getLocalImageFile(
      widget.episode.imageUrl,
      widget.episode.imageFileName,
      widget.episode.imageFileSize,
    );
    if (_lFile == 'none') {
      if (_imageUrl != widget.episode.imageUrl && mounted)
        setState(() {
          _imageUrl = widget.episode.imageUrl;
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

  Future<void> _launch(String url) async {
    if (await canLaunch(url)) await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.episode.imageUrl.length > 0 &&
        _imageUrl == 'none' &&
        _localImageFile == 'none') {
      _resetImageUrl();
    }
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text(widget.episode.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(3.0),
          child: Container(
            decoration: myBoxDecoration(appColors.ivory),
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: Column(
                children: [
                  if (_localImageFile == 'none' && _imageUrl != 'none') ...[
                    Image.network(_imageUrl),
                  ],
                  if (_localImageFile != 'none' && _imageUrl == 'none') ...[
                    Image.file(File(_localImageFile)),
                  ],
                  Html(
                      data: getHtml(widget.episode.desc),
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
      ),
    );
  }
}
