import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: PhotoView(
          backgroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }
}