import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'chat.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }
}