import 'package:flutter/material.dart';
import '../episode/description.dart';
import '../item_image/item_image.dart';
import 'episode_play_button.dart';
import 'item_seek_bar.dart';
import 'func_mixin.dart';
import '../database/data_classes.dart';
import '../constants.dart';
import '../pref_utils.dart';

abstract class EpisodeItemRowMixin<T extends StatefulWidget>
    extends FuncMixin<T> {
  int currentEpisode = -1;

  void updateCurrentEpisode() {
    getCurrentEpisode().then((int _eid) {
      if (_eid != currentEpisode) {
        setState(() {
          currentEpisode = _eid;
        });
      }
    });
  }

  Future<void> goToEpisodeDescription(
      ScrollableEpisode scrollableEpisode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodeItemDesc(
          episode: scrollableEpisode,
        ),
      ),
    );
  }

  Padding feedItemRow(
      ScrollableEpisode scrollableEpisode, int itemNo, int currentEpisode) {
    return Padding(
      key: Key('padding_$itemNo'),
      padding: EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 3.0,
      ),
      child: Container(
        decoration: myBoxDecoration(appColors.ivory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              goToEpisodeDescription(scrollableEpisode);
            },
            child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: (scrollableEpisode.imageUrl.length > 0)
                              ? ItemImage(
                                  key: Key('item_image_$itemNo'),
                                  imageUrl: scrollableEpisode.imageUrl,
                                  imageFileName:
                                      scrollableEpisode.imageFileName,
                                  imageFileSize:
                                      scrollableEpisode.imageFileSize,
                                )
                              : Container(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              "${scrollableEpisode.title}",
                              key: Key('feed_title_$itemNo'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          height: 48,
                          child: EpisodePlayButton(
                            episodeID: scrollableEpisode.id,
                            episodeTitle: scrollableEpisode.title,
                            feedTitle: scrollableEpisode.feed,
                            currentEpisode: currentEpisode,
                            updateCurrentEpisode: updateCurrentEpisode,
                          ),
                        ),
                      ],
                    ),
                    ItemSeekBar(
                      episodeTitle: scrollableEpisode.title,
                      feedTitle: scrollableEpisode.feed,
                      fullScreen: false,
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
