import 'package:flutter/material.dart';

import '../constants.dart';
import '../database/data_classes.dart';
import '../episode/main.dart';
import '../feed_options/feed_options.dart';
import '../item_image/item_image.dart';
import 'func_mixin.dart';

abstract class FeedItemRowMixin<T extends StatefulWidget> extends FuncMixin<T> {
  Future<void> goToEpisodeScreen(String title, int fid) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Episode(
                title: title,
                feedID: fid,
              )),
    );
  }

  Future<void> goToFeedOptions(
      String _title, String _desc, int _fid, String _imageDesc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedOptions(
          feedTitle: _title,
          feedDesc: _desc,
          feedID: _fid,
          feedImageDesc: _imageDesc,
        ),
      ),
    );
  }

  Padding feedItemRow(ScrollableFeed scrollableFeed, int itemNo) {
    return Padding(
      key: Key('padding_$itemNo'),
      padding: EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 3.0,
      ),
      child: Container(
        key: Key('inkwell_$itemNo'),
        decoration: myBoxDecoration(appColors.ivory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              goToEpisodeScreen(
                scrollableFeed.title,
                scrollableFeed.id,
              );
            },
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: (scrollableFeed.imageUrl.length > 0)
                        ? ItemImage(
                            key: Key('item_image_$itemNo'),
                            imageUrl: scrollableFeed.imageUrl,
                            imageFileName: scrollableFeed.imageFileName,
                            imageFileSize: scrollableFeed.imageFileSize,
                          )
                        : Container(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Text(
                        "${scrollableFeed.title}",
                        key: Key('feed_title_$itemNo'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 2,
                    child: IconButton(
                      onPressed: () {
                        goToFeedOptions(
                          scrollableFeed.title,
                          scrollableFeed.desc,
                          scrollableFeed.id,
                          scrollableFeed.imageDesc,
                        );
                      },
                      icon: Icon(Icons.info_outline_rounded),
                      iconSize: 24,
                      color: Colors.black87,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
