import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class QRScanScreen extends StatefulWidget {
  final File pickedImage;
  final String result;
  const QRScanScreen(
      {Key? key, required this.pickedImage, required this.result})
      : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  var result = '';
  String _pickedImage = '';
  String? imagePath;

  Future<void> decodeBarCode() async {
    print('decodeBarCode called');
    result = '';
    FirebaseVisionImage myImage =
        FirebaseVisionImage.fromFile(File(imagePath!));
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(myImage);
    for (Barcode readableCode in barCodes) {
      setState(() {
        result = readableCode.displayValue;
      });
    }
    print(result);
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
      imagePath = pickedImageFile!.path;
    });
  }

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
                decodeBarCode();
              });
            }),
        SpeedDialChild(
            child: Icon(
              MaterialCommunityIcons.camera,
              color: Color(0xFF7579E7),
            ),
            onTap: () {
              _pickImageCamera().then((value) {
                decodeBarCode();
              });
            }),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('qr_scan_screen');
    result = widget.result;
    imagePath = widget.pickedImage.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100.0),
                // barcode image
                Center(
                  child: Container(
                    height: 250.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(imagePath!)),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                // result
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(
                      'Fira Sans',
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
                // copy text button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    print(result);
                    if (result != '') {
                      Clipboard.setData(
                        ClipboardData(text: result),
                      );
                      Fluttertoast.showToast(
                        msg: 'Copied to Clipboard',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.black,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Empty Result',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: Text(
                    'Copy Text',
                    style: GoogleFonts.getFont(
                      'Fira Sans',
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }
}
