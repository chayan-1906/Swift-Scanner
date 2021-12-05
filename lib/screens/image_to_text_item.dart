import 'dart:io';

import 'package:flutter/material.dart';

class ImageToTextItem extends StatefulWidget {
  final File pickedImageFile;
  const ImageToTextItem({Key? key, required this.pickedImageFile})
      : super(key: key);

  @override
  _ImageToTextItemState createState() => _ImageToTextItemState();
}

class _ImageToTextItemState extends State<ImageToTextItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent.shade100,
              Colors.blueAccent.shade100,
              Colors.yellowAccent.shade100,
              Colors.redAccent.shade100,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.75,
            child: Image.file(
              widget.pickedImageFile,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
