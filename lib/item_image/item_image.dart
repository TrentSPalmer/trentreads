import 'dart:io';
import 'package:flutter/material.dart';
import '../download/images.dart';

class ItemImage extends StatefulWidget {
  final String imageUrl;
  final String imageFileName;
  final int imageFileSize;

  ItemImage({
    required this.imageUrl,
    required this.imageFileName,
    required this.imageFileSize,
    Key? key,
  }) : super(key: key);

  @override
  ItemImageState createState() => ItemImageState();
}

class ItemImageState extends State<ItemImage> {
  String _imageUrl = 'none';
  String _localImageFile = 'none';

  Future<void> _resetImageUrl() async {
    String _lFile = await getLocalImageFile(
      widget.imageUrl,
      widget.imageFileName,
      widget.imageFileSize,
    );
    if (_lFile == 'none') {
      if (_imageUrl != widget.imageUrl && mounted)
        setState(() {
          _imageUrl = widget.imageUrl;
          _localImageFile = 'none';
        });
    } else {
      if (_localImageFile != _lFile && mounted)
        setState(() {
          _localImageFile = _lFile;
          _imageUrl = 'none';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.length > 0 &&
        _imageUrl == 'none' &&
        _localImageFile == 'none') {
      _resetImageUrl();
    }
    if (_imageUrl == 'none' && _localImageFile == 'none') {
      return Container();
    } else {
      if (_localImageFile == 'none') {
        return Image.network(
          _imageUrl,
          width: 64,
          height: 64,
        );
      } else {
        return Image.file(
          File(_localImageFile),
          width: 64,
          height: 64,
        );
      }
    }
  }
}
