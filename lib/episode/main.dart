import 'package:flutter/material.dart';
import 'package:trentreads/widgets.dart';

import '../constants.dart';
import '../database/data_classes.dart';
import '../episode/episode_downloaders.dart';
import '../mini_player/mini_player.dart';
import '../pref_utils.dart';
import 'episode_item_row_mixin.dart';

class Episode extends StatefulWidget {
  final String title;
  final int feedID;

  Episode({
    Key? key,
    required this.title,
    required this.feedID,
  }) : super(key: key);

  @override
  EpisodeState createState() => EpisodeState();
}

class EpisodeState extends EpisodeItemRowMixin<Episode> {
  bool active = false;

  Future<bool> _popBack() async {
    Navigator.pop(context, 1);
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    getEpisodeList(widget.feedID)
        .then((value) => {
              if (mounted)
                setState(() {
                  episodeList = value;
                })
            })
        .then((value) => {checkEpisodesExpired(widget.feedID)});
  }

  Widget _buildDataList() {
    return ListView.builder(
      controller: scrollController,
      itemCount: verifiedEpisodeListLength(widget.feedID),
      itemBuilder: (context, i) {
        return FutureBuilder<ScrollableEpisode>(
          future: getRow(i),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return (feedItemRow(
                  (snapshot.data ?? emptyEpisode), i, currentEpisode));
            } else if (snapshot.hasError) {
              return (feedItemRow(emptyEpisode, i, currentEpisode));
            } else {
              return (feedItemRow(emptyEpisode, i, currentEpisode));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!active) {
      getCurrentEpisode().then((int _ce) {
        if (_ce > -1) {
          setState(() {
            active = true;
          });
        }
      });
    }

    return WillPopScope(
      onWillPop: _popBack,
      child: Scaffold(
        backgroundColor: appColors.peacockBlue,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: (episodeList.length > 0)
                  ? _buildDataList()
                  : loadingSpinner(),
            ),
            if (active) ...[
              MiniPlayer(),
            ]
          ],
        ),
      ),
    );
  }
}
