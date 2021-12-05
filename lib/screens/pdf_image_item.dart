import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';

class PDFImageItem extends StatefulWidget {
  final String pdfName;
  final image;
  final List pdfImages;
  final int index;
  final String pdfCreationDate;
  final Timestamp timestamp;

  const PDFImageItem({
    Key? key,
    required this.pdfName,
    required this.image,
    required this.pdfImages,
    required this.index,
    required this.pdfCreationDate,
    required this.timestamp,
  }) : super(key: key);

  @override
  _PDFImageItemState createState() => _PDFImageItemState();
}

class _PDFImageItemState extends State<PDFImageItem> {
  File? imageFile;

  @override
  void initState() {
    super.initState();
    imageFile = widget.image;
  }

  cropImage() async {
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop',
        toolbarColor: Color(0xffc69f50),
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );
    if (croppedFile != null) {
      setState(() {
        imageFile = croppedFile;
        widget.pdfImages.removeAt(widget.index);
        widget.pdfImages.insert(widget.index, imageFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar();
    print('${widget.pdfName}');

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        return Future.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // appbar
              Container(
                height: appBar.preferredSize.height,
                width: appBar.preferredSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25.0),
                  ),
                  color: Colors.redAccent,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // pdf name
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: AutoSizeText(
                            widget.pdfName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              'Fira Sans',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // cropper
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () async {
                            cropImage();
                          },
                          icon: Icon(MaterialIcons.crop_free),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // image to be cropped
              Flexible(
                child: Center(
                  child: Container(
                    color: Colors.lightBlueAccent,
                    // height: MediaQuery.of(context).size.height * 0.75,
                    child: imageFile == null
                        ? Container()
                        : Image.file(imageFile!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
