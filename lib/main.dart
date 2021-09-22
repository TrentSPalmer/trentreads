import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'home/feeds.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trent Reads',
      theme: ThemeData(
        primaryColor: appColors.navy,
      ),
      home: AudioServiceWidget(child: MainScreen()),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FeedWidget();
  }
}
