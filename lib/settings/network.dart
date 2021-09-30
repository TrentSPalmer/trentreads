import 'package:flutter/material.dart';

import '../constants.dart';
import '../pref_utils.dart';
import '../widgets.dart';

class NetworkSettings extends StatefulWidget {
  @override
  NetworkSettingsState createState() => NetworkSettingsState();
}

class NetworkSettingsState extends State<NetworkSettings> {
  bool mobileDownLoadOK = true;

  Future<void> isMobileDownLoadOK() async {
    getMobileDownLoadOK().then((bool _ok) => {
          if (_ok != mobileDownLoadOK && mounted)
            setState(() {
              mobileDownLoadOK = _ok;
            })
        });
  }

  void toggleMobileDownLoadOK(bool _ok) {
    setMobileDownLoadOK(_ok).then((int x) => {
          if (mounted)
            setState(() {
              mobileDownLoadOK = _ok;
            })
        });
  }

  @override
  Widget build(BuildContext context) {
    isMobileDownLoadOK();
    return Scaffold(
      backgroundColor: appColors.peacockBlue,
      appBar: AppBar(
        title: Text('Network Settings'),
      ),
      body: Column(
        children: [
          switchTile(
            "Enable Automatic Downloads to Local Storage when connected to Mobile Network?",
            mobileDownLoadOK,
            toggleMobileDownLoadOK,
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
