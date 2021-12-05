import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:swift_scanner/screens/bottom_bar_screens/user_info_screen.dart';
import 'package:swift_scanner/screens/pdf_images_screen.dart';
import 'package:swift_scanner/screens/pdf_view_screen.dart';

import 'loading.dart';

FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

class SpeedDialFAB extends StatefulWidget {
  const SpeedDialFAB({Key? key}) : super(key: key);

  @override
  _SpeedDialFABState createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB> {
  ProgressDialog? progressDialog;
  List _images = [];
  String _pickedImage = '';

  Widget buildFloatingActionButton(BuildContext context) {
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var pdfCreationDate =
        '${dateParse.day}-${dateParse.month}-${dateParse.year} ${dateParse.hour}:${dateParse.minute}:${dateParse.second}';
    var defaultPdfName =
        'SwiftScanner_${dateParse.day}-${dateParse.month}-${dateParse.year} ${dateParse.hour}-${dateParse.minute}-${dateParse.second}';
    var timestamp = Timestamp.now();
    return SpeedDial(
      icon: MaterialIcons.add_a_photo,
      backgroundColor: Color(0xFF7579E7),
      overlayColor: Colors.white,
      overlayOpacity: 0.4,
      children: [
        SpeedDialChild(
          child: Icon(
            MaterialCommunityIcons.file_upload,
            color: Color(0xFF7579E7),
          ),
          onTap: () async {
            getPdfAndUpload(context);
          },
        ),
        SpeedDialChild(
            child: Icon(
              MaterialCommunityIcons.image,
              color: Color(0xFF7579E7),
            ),
            onTap: () {
              _images.clear();
              _pickImageGallery().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return PDFImagesScreen(
                      pdfName: defaultPdfName,
                      pdfImages: _images,
                      pdfCreationDate: pdfCreationDate,
                      timestamp: timestamp,
                    );
                  }),
                );
              });
            }),
        SpeedDialChild(
            child: Icon(
              MaterialCommunityIcons.camera,
              color: Color(0xFF7579E7),
            ),
            onTap: () {
              _images.clear();
              _pickImageCamera().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return PDFImagesScreen(
                      pdfName: defaultPdfName,
                      pdfImages: _images,
                      pdfCreationDate: pdfCreationDate,
                      timestamp: timestamp,
                    );
                  }),
                );
              });
            }),
      ],
    );
  }

  Future<void> _pickImageCamera() async {
    String imagePath;
    try {
      imagePath = (await EdgeDetection.detectEdge)!;
      imagePath == null ? null : File(imagePath);
      _images.add(File(imagePath));
      print(imagePath);
      setState(() {
        _pickedImage = imagePath;
      });
    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _pickedImage = imagePath;
    });
  }

  Future<void> _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    final pickedImageFile = pickedImage == null ? null : File(pickedImage.path);
    _images.add(File(pickedImageFile!.path));
    setState(() {
      // _pickedImage = pickedImageFile;
    });
  }

  Future<void> getPdfAndUpload(BuildContext context) async {
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    File? file = File(filePickerResult!.files.single.path!);
    print('file: ${basename(file.path)}');
    String fileName = basename(file.path) + '_$dateParse';
    uploadFile(context, file, fileName);
  }

  uploadFile(BuildContext context, File file, String fileName) async {
    String _pdfUrl = '';
    if (file == null) return null;
    if (_firebaseAuth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pinkAccent.shade100,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              'Please sign in to upload',
              style: GoogleFonts.getFont(
                'Fira Sans',
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
      await progressDialog!.hide();
      return;
    }
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('pdfs')
        .child(fileName)
        .child('$fileName.pdf');
    print('Uploading in storage...!');
    await progressDialog!.show();
    await storageReference.putFile(file).then((p0) async {
      _pdfUrl = await storageReference.getDownloadURL();
      print('Uploaded in storage...!');
      print('Uploading in firestore...!');
      saveToFirestore(context, _pdfUrl, fileName).then((value) async {
        print('Uploaded in firestore...!');
        await progressDialog!.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pinkAccent.shade100,
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                'PDF uploaded successfully!',
                style: GoogleFonts.getFont(
                  'Fira Sans',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      });
    });
    print('pdfUrl: $_pdfUrl');
  }

  Future<void> saveToFirestore(
      BuildContext context, String _pdfUrl, String fileName) async {
    // FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var pdfCreationDate =
        '${dateParse.day}/${dateParse.month}/${dateParse.year} ${dateParse.hour}:${dateParse.minute}';
    var timestamp = Timestamp.now();
    await _firebaseFirestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pdfs')
        .doc(fileName)
        .set({
      'pdfUrl': _pdfUrl,
      'pdfName': fileName,
      'pdfActualName': fileName,
      'pdfCreationDate': pdfCreationDate,
      'timestamp': timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    // progressDialog!.style(
    //   message: 'Uploading file...',
    //   borderRadius: 10.0,
    //   backgroundColor: Colors.white,
    //   elevation: 10.0,
    //   insetAnimCurve: Curves.easeInOut,
    //   messageTextStyle: GoogleFonts.getFont(
    //     'Fira Sans',
    //     fontSize: 20.0,
    //     fontWeight: FontWeight.w600,
    //   ),
    // );
    return buildFloatingActionButton(context);
  }
}

class CustomTextButtonIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Function() onTap;

  const CustomTextButtonIcon({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 5.0),
          Text(
            title,
            style: GoogleFonts.getFont(
              'Fira Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PDFItem extends StatefulWidget {
  const PDFItem({Key? key}) : super(key: key);

  @override
  State<PDFItem> createState() => _PDFItemState();
}

class _PDFItemState extends State<PDFItem> {
  // final pdf = PdfImageRendererPdf(path: '');
  // var pdfFrontPageImage;

  // void renderPdfImage() async {
  //   // Get a path from a pdf file (we are using the file_picker package (https://pub.dev/packages/file_picker))
  //   // String path = await FilePicker.platform
  //   //     .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
  //
  //   final pdf = PdfImageRendererPdf(path: '');
  //   await pdf.open();
  //   await pdf.openPage(pageIndex: 0);
  //   // final size = await pdf.getPageSize(pageIndex: 0);
  //   final img = await pdf.renderPage(
  //     pageIndex: 0,
  //     x: 0,
  //     y: 0,
  //     width: 100,
  //     height: 100,
  //     scale: 1,
  //     background: Colors.white,
  //   );
  //   await pdf.closePage(pageIndex: 0);
  //   pdf.close();
  //   setState(() {
  //     pdfFrontPageImage = img;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firebaseFirestore
            .collection('users')
            .doc('${_firebaseAuth.currentUser!.uid}')
            .collection('pdfs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return SinglePdf(
                      context,
                      // pdfFrontPageImage: pdfFrontPageImage,
                      pdfName: snapshot.data!.docs[index]['pdfName'],
                      pdfCreationDate: snapshot.data!.docs[index]
                          ['pdfCreationDate'],
                      // pdfNoOfPages: '1',
                      pdfUrl: snapshot.data!.docs[index]['pdfUrl'],
                    );
                  });
            } else {
              return Container();
            }
          }
          return Loading();
        });
  }

  Container SinglePdf(
    BuildContext context, {
    // required String pdfFrontPageImage,
    required String pdfName,
    required String pdfCreationDate,
    // required String pdfNoOfPages,
    required String pdfUrl,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: PDFViewScreen(
                pdfUrl: pdfUrl,
                pdfName: pdfName,
                pdfCreationDate: pdfCreationDate,
              ),
            ),
          );
        },
        onLongPress: () {
          // TODO: EDIT PDF, GO TO PDF_IMAGES_SCREEN
          print('onLongPress');
        },
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 100.0),
              // Image.network(pdfFrontPageImage),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // pdf name
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: AutoSizeText(
                      pdfName,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.getFont(
                        'Fira Sans',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // pdf creation date
                  AutoSizeText(
                    pdfCreationDate,
                    style: GoogleFonts.getFont(
                      'Fira Sans',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  // pdf no of pages
                  /*Row(
                    children: [
                      Icon(MdiIcons.bookOpenPageVariant, size: 16.0),
                      SizedBox(width: 5.0),
                      Text(
                        pdfNoOfPages,
                        style: GoogleFonts.getFont(
                          'Fira Sans',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget backLayerMenu(BuildContext context) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Ink(
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
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      SingleChildScrollView(
        child: UserInfoScreen(),
      ),
    ],
  );
}
