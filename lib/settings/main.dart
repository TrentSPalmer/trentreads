import 'package:flutter/material.dart';
import 'global_download_settings.dart';
import '../constants.dart';
import '../widgets.dart';
import 'network.dart';
import 'storage.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          navTile(context, StorageSetting(), "Select Storage Device"),
          navTile(context, GlobalDownLoadSettings(), "Download Settings"),
          navTile(context, NetworkSettings(), "Network Settings"),
        ],
      ),
    );
  }
}
