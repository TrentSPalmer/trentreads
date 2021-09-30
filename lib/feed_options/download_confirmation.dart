import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets.dart';

class DownLoadConfirmation extends StatelessWidget {
  final String feedTitle;
  final int numEpisodes;
  final int numNotDownloadedEpisodes;

  DownLoadConfirmation({
    required this.feedTitle,
    required this.numEpisodes,
    required this.numNotDownloadedEpisodes,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _x = "$numNotDownloadedEpisodes of $numEpisodes episodes ";
    String _y = "will be downloaded for $feedTitle";
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('Download Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 3.0,
                  ),
                  child: Container(
                    decoration: myBoxDecoration(appColors.ivory),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "$_x$_y",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: Container()),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              okButton(context, 2),
            ],
          ),
        ],
      ),
    );
  }
}
