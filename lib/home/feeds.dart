import 'package:flutter/material.dart';
import '../database/data_classes.dart';
import 'feed_item_row_mixin.dart';
import '../constants.dart';
import '../pref_utils.dart';
import '../mini_player/mini_player.dart';
import '../settings/main.dart';

class FeedWidget extends StatefulWidget {
  FeedWidget({
    Key? key,
  }) : super(key: key);

  @override
  FeedState createState() => FeedState();
}

class FeedState extends FeedItemRowMixin<FeedWidget> {
  bool active = false;

  Widget _buildDataList() {
    if (!active) {
      getCurrentEpisode().then((int _ce) {
        if (_ce > -1) {
          setState(() {
            active = true;
          });
        }
      });
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: feedList.length,
      itemBuilder: (context, i) {
        return FutureBuilder<ScrollableFeed>(
          future: getRow(i),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return (feedItemRow((snapshot.data ?? empty), i));
            } else if (snapshot.hasError) {
              return (feedItemRow(empty, i));
            } else {
              return (feedItemRow(empty, i));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('Feeds'),
        actions: [
          IconButton(
            key: Key('feed_page_settings_icon'),
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: _buildDataList(),
            ),
          ),
          if (active) ...[
            MiniPlayer(),
          ]
        ],
      ),
    );
  }
}
