import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'image_to_text_item.dart';

class ImageToTextScreen extends StatefulWidget {
  const ImageToTextScreen({Key? key}) : super(key: key);

  @override
  _ImageToTextScreenState createState() => _ImageToTextScreenState();
}

class _ImageToTextScreenState extends State<ImageToTextScreen> {
  String result = '';
  String? imagePath;
  String _pickedImage = '';

  Widget _buildFloatingActionButton(BuildContext context) {
    return SpeedDial(
      icon: MaterialIcons.add_a_photo,
      backgroundColor: Color(0xFF7579E7),
      overlayColor: Colors.white,
      overlayOpacity: 0.4,
      children: [
        SpeedDialChild(
            child: Icon(
              MaterialCommunityIcons.image,
              color: Color(0xFF7579E7),
            ),
            onTap: () {
              _pickImageGallery().then((value) {
                _convertImageToText(context);
              });
            }),
        SpeedDialChild(
            child: Icon(
              MaterialCommunityIcons.camera,
              color: Color(0xFF7579E7),
            ),
            onTap: () {
              _pickImageCamera().then((value) {
                _convertImageToText(context);
              });
            }),
      ],
    );
  }

  Future<void> _pickImageCamera() async {
    try {
      imagePath = (await EdgeDetection.detectEdge)!;
      imagePath == null ? null : File(imagePath!);
      print(imagePath);
      setState(() {
        _pickedImage = imagePath!;
      });
    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _pickedImage = imagePath!;
    });
  }

  Future<void> _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    final pickedImageFile = pickedImage == null ? null : File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile!.path;
      imagePath = pickedImageFile.path;
    });
  }

  Future<void> _convertImageToText(BuildContext context) async {
    try {
      // imagePath = (await EdgeDetection.detectEdge)!;
      imagePath == null ? null : File(imagePath!);
      print(imagePath);
      result = '';
      FirebaseVisionImage firebaseVisionImage =
          FirebaseVisionImage.fromFile(File(imagePath!));
      TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
      VisionText readText =
          await recognizeText.processImage(firebaseVisionImage);
      for (TextBlock block in readText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement word in line.elements) {
            print(word.text);
            setState(() {
              result = result + ' ' + word.text;
            });
          }
        }
      }
      print(result);
    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // picked image
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: _pickedImage != ''
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageToTextItem(
                                  pickedImageFile: File(_pickedImage),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      height: 280.0,
                      width: MediaQuery.of(context).size.width / 1.6,
                      margin:
                          EdgeInsets.only(top: 10.0, bottom: 10.0, right: 30.0),
                      child: _pickedImage == ''
                          ? Image(
                              image: AssetImage('assets/images/pin.png'),
                              fit: BoxFit.fill,
                            )
                          : Image.file(File(_pickedImage)),
                    ),
                  ),
                ),
              ),
              // converted text
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 280.0,
                  padding: EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width / 1.6,
                  margin: EdgeInsets.only(top: 10.0, bottom: 20.0, left: 30.0),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/note.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      onTap: result != ''
                          ? () {
                              Clipboard.setData(
                                ClipboardData(text: result),
                              );
                              Fluttertoast.showToast(
                                msg: "Copied to Clipboard",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          result,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.getFont(
                            'Fira Sans',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }
}
