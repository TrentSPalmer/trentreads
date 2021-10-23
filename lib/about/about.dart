import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'about_html.dart';
import '../constants.dart';

class TrentReadsAboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return Scaffold(
      backgroundColor: appColors.ivory,
      appBar: AppBar(
        title: Text('About TrentReads'),
      ),
      body: SingleChildScrollView(
        child: aboutHtml(),
      ),
    );
  }
}
