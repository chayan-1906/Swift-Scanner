import 'dart:io';

import 'package:backdrop/app_bar.dart';
import 'package:backdrop/button.dart';
import 'package:backdrop/scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:swift_scanner/widgets/home_screen_widgets.dart';

import '../image_to_text_screen.dart';
import '../pdf_images_screen.dart';
import '../qr_scan_screen.dart';
import '../scan_id_card_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  var result = '';
  ProgressDialog? progressDialog;
  String _pickedImage = '';
  List<File> _images = [];
  String _uid = '';
  String _userImageUrl = '';

  Future<void> _pickImageCamera() async {
    String imagePath;
    print('_pickImageCamera');
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

  Future<void> decodeBarCode() async {
    print('decodeBarCode called');
    result = '';
    FirebaseVisionImage myImage =
        FirebaseVisionImage.fromFile(File(_pickedImage));
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(myImage);
    for (Barcode readableCode in barCodes) {
      setState(() {
        result = readableCode.displayValue;
      });
    }
    print(result);
  }

  getUserImageUrl() async {
    User? user = _firebaseAuth.currentUser;
    _uid = user!.uid;
    if (user.isAnonymous) {
      _userImageUrl =
          'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg';
      return;
    }
    final DocumentSnapshot<Map<String, dynamic>>? documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    print('documentSnapshot: ${documentSnapshot}');
    setState(() {
      _userImageUrl = documentSnapshot!.get('imageUrl') ??
          'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var pdfCreationDate =
        '${dateParse.day}-${dateParse.month}-${dateParse.year} ${dateParse.hour}:${dateParse.minute}:${dateParse.second}';
    var defaultPdfName =
        'SwiftScanner_${dateParse.day}-${dateParse.month}-${dateParse.year} ${dateParse.hour}-${dateParse.minute}-${dateParse.second}';
    var defaultIDCardName =
        'ID card ${dateParse.day}-${dateParse.month}-${dateParse.year} ${dateParse.hour}:${dateParse.minute}:${dateParse.second}';
    var timestamp = Timestamp.now();

    return BackdropScaffold(
      headerHeight: MediaQuery.of(context).size.height * 0.45,
      resizeToAvoidBottomInset: false,
      appBar: BackdropAppBar(
        title: Text(
          'Swift Scanner',
          style: GoogleFonts.getFont(
            'Fira Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackdropToggleButton(icon: AnimatedIcons.home_menu),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pinkAccent.shade100,
                Colors.blueAccent.shade100,
                Colors.yellowAccent.shade100,
                Colors.redAccent.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            iconSize: 15.0,
            padding: const EdgeInsets.all(10.0),
            icon: CircleAvatar(
              radius: 15.0,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 13.0,
                backgroundImage: NetworkImage(_userImageUrl != ''
                    ? _userImageUrl
                    : 'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg'),
              ),
            ),
          )
        ],
      ),
      backLayer: backLayerMenu(context),
      frontLayer: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent.shade100,
              Colors.blueAccent.shade100,
              Colors.yellowAccent.shade100,
              Colors.redAccent.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // search text field
              /*GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
                  height: MediaQuery.of(context).size.height / 8,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      hintText: 'Search',
                      hintStyle: GoogleFonts.getFont(
                        'Fira Sans',
                        fontSize: 16.0,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon:
                          Icon(MaterialCommunityIcons.file_document_box_search),
                      enabled: false,
                    ),
                  ),
                ),
              ),*/
              // tools
              Container(
                padding:
                    const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomTextButtonIcon(
                            title: 'Smart Scan',
                            icon: MdiIcons.camera,
                            color: Color(0xFF00A19D),
                            onTap: () {
                              print('_pickImageCamera');
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
                            },
                          ),
                          CustomTextButtonIcon(
                            title: 'Import Picture',
                            icon: EvaIcons.image2,
                            color: Color(0xFF39A388),
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
                            },
                          ),
                          CustomTextButtonIcon(
                            title: 'Import File',
                            icon: MaterialCommunityIcons.file_upload,
                            color: Colors.orange.shade800,
                            onTap: () async {
                              getPdfAndUpload(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomTextButtonIcon(
                            title: 'Scan ID Card',
                            icon: MdiIcons.idCard,
                            color: Color(0xFF7C83FD),
                            onTap: () {
                              print('_pickImageCamera');
                              _images.clear();
                              _pickImageCamera().then((value) {
                                print('first image: $_pickedImage');
                                _pickedImage = '';
                                _pickImageCamera().then((value) {
                                  print('second image: $_pickedImage');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ScanIdCardScreen(
                                        idCardName: defaultIDCardName,
                                        idCardImages: _images,
                                        pdfCreationDate: pdfCreationDate,
                                        timestamp: timestamp,
                                      );
                                    }),
                                  );
                                });
                              });
                            },
                          ),
                          CustomTextButtonIcon(
                            title: 'Image to Text',
                            icon: MdiIcons.imageText,
                            color: Color(0xFF39A388),
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return ImageToTextScreen();
                                }),
                              );
                            },
                          ),
                          CustomTextButtonIcon(
                            title: 'QR Scan',
                            icon: MaterialCommunityIcons.qrcode,
                            color: Colors.indigoAccent,
                            onTap: () async {
                              _pickImageCamera().then((value) {
                                decodeBarCode().then((value) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return QRScanScreen(
                                        pickedImage: File(_pickedImage),
                                        result: result,
                                      );
                                    }),
                                  );
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // all docs
              Visibility(
                visible: _firebaseAuth.currentUser != null,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'All Docs',
                    style: GoogleFonts.getFont(
                      'Fira Sans',
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // listview
              Flexible(
                child: PDFItem(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
