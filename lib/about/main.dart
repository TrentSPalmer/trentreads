import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about.dart';
import '../constants.dart';
import '../widgets.dart';

Future<void> showLicense() async {
  String license_url =
      "https://github.com/TrentSPalmer/trentreads/blob/master/LICENSE";
  if (await canLaunch(license_url)) {
    await launch(license_url);
  } else {
    throw "Could not launch $license_url.";
  }
}

class AboutTrentReads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> showOtherLicenses() async {
      showLicensePage(context: context);
    }

    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('About TrentReads'),
      ),
      body: Column(
        children: [
          navTile(context, TrentReadsAboutPage(), "About TrentReads"),
          functionTile(
            "License",
            showLicense,
          ),
          functionTile(
            "Other Licenses",
            showOtherLicenses,
          ),
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              homeButton(context, 2),
              Expanded(
                child: Container(),
              ),
              okButton(context, 1),
            ],
          ),
        ],
      ),
    );
  }
}
