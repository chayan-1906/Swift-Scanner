import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidget;
import 'package:progress_dialog/progress_dialog.dart';

import 'bottom_bar_screen.dart';
import 'pdf_image_item.dart';

class PDFImagesScreen extends StatefulWidget {
  final String pdfName;
  final List pdfImages;
  final String pdfCreationDate;
  final Timestamp timestamp;

  const PDFImagesScreen({
    Key? key,
    required this.pdfName,
    required this.pdfImages,
    required this.pdfCreationDate,
    required this.timestamp,
  }) : super(key: key);

  @override
  _PDFImagesScreenState createState() => _PDFImagesScreenState();
}

class _PDFImagesScreenState extends State<PDFImagesScreen> {
  String _pickedImage = '';
  String _pdfUrl = '';
  late List tmpList;
  late List images;
  int variableSet = 0;
  // ScrollController? _scrollController;
  int? pos;
  double? width;
  double? height;
  ProgressDialog? progressDialog;
  var pdf = pdfWidget.Document();
  bool back = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  // late TextEditingController _renamePdfController;

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
              _pickImageGallery();
            }),
        SpeedDialChild(
            child: Icon(
              MaterialCommunityIcons.camera,
              color: Color(0xFF7579E7),
            ),
            onTap: () {
              _pickImageCamera();
            }),
      ],
    );
  }

  Future<void> _pickImageCamera() async {
    String imagePath;
    try {
      imagePath = (await EdgeDetection.detectEdge)!;
      imagePath == null ? null : File(imagePath);
      images.add(File(imagePath));
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
    images.add(File(pickedImageFile!.path));
    setState(() {
      // _pickedImage = pickedImageFile;
    });
  }

  Future<void> customAlertDialog(BuildContext context, String title,
      String subtitle, Function func) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Image.asset(
                  'assets/images/warning.png',
                  height: 20.0,
                  width: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: GoogleFonts.getFont(
                    'Fira Sans',
                    fontSize: 18.0,
                    letterSpacing: 1.1,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            subtitle,
            style: GoogleFonts.getFont(
              'Fira Sans',
              fontSize: 14.0,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.getFont(
                  'Fira Sans',
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                func();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.getFont(
                  'Roboto Slab',
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _createPdfFile() async {
    for (var img in images) {
      final image = pdfWidget.MemoryImage(img.readAsBytesSync());
      pdf.addPage(
        pdfWidget.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pdfWidget.Context context) {
            return pdfWidget.Center(
              child: pdfWidget.Image(image),
            );
          },
        ),
      );
    }
  }

  _savePdfFile() async {
    try {
      final dir = await getExternalStorageDirectory();
      final pdfFile = File('${dir!.path}/${widget.pdfName}.pdf');
      await pdfFile.writeAsBytes(await pdf.save());
      // pdf saved snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent.shade100,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: AutoSizeText(
              'Pdf Saved at ${dir.path}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.getFont(
                'Fira Sans',
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
      // please sign in to upload snackbar
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
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: BottomBarScreen(),
          ),
        );
        return;
      }
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('pdfs')
          .child(widget.pdfName)
          .child('${widget.pdfName}.pdf');
      print('Uploading in storage...!');
      await progressDialog!.show();
      await storageReference.putFile(pdfFile).then((p0) async {
        _pdfUrl = await storageReference.getDownloadURL();
        print('Uploaded in storage...!');
        print('Uploading in firestore...!');
        await _firebaseFirestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('pdfs')
            .doc(widget.pdfCreationDate)
            .set({
          'pdfUrl': _pdfUrl,
          'pdfName': widget.pdfName,
          'pdfActualName': widget.pdfName,
          'pdfCreationDate': widget.pdfCreationDate,
          'timestamp': widget.timestamp,
        }).then((value) async {
          print('Uploaded in firestore...!');
          await progressDialog!.hide();
          // uploaded in firestore
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
      // Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: BottomBarScreen(),
        ),
      );
      print('saved in ${dir.path}/${widget.pdfName}.pdf');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tmpList = widget.pdfImages;
    images = widget.pdfImages;
  }

  /*Future<void> _renamePdfDialog() async {
    print('_renamePdfDialog');
    _renamePdfController = TextEditingController(text: widget.pdfName);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text(
              'Rename',
              style: GoogleFonts.getFont(
                'Fira Sans',
                fontSize: 20.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: TextFormField(
              controller: _renamePdfController,
              // initialValue: widget.pdfName,
              style: GoogleFonts.getFont(
                'Fira Sans',
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            elevation: 8.0,
            actions: [
              // okay button
              TextButton(
                onPressed: () {
                  _renamePdf();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Okay',
                  style: GoogleFonts.getFont(
                    'Fira Sans',
                    fontSize: 18.0,
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // discard button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Discard',
                  style: GoogleFonts.getFont(
                    'Fira Sans',
                    fontSize: 18.0,
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _renamePdf() async {
    final QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('pdfs')
        .where(widget.pdfName)
        .get();
    if (querySnapshot.docs.length >= 1) {
      await _firebaseFirestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .collection('pdfs')
          .doc(widget.pdfName)
          .update({'pdfName': _renamePdfController.text});
    } else {
      await _firebaseFirestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .collection('pdfs')
          .doc(widget.pdfName)
          .set({'pdfName': _renamePdfController.text});
    }
  }*/

  @override
  Widget build(BuildContext context) {
    print('${widget.pdfName}');
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      customBody: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/double_ring_loading_io.gif',
              height: 50.0,
              width: 50.0,
            ),
            SizedBox(width: 10.0),
            Flexible(
              child: AutoSizeText(
                'Saving...',
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: GoogleFonts.getFont(
                  'Fira Sans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return images.isEmpty
        ? BottomBarScreen()
        : WillPopScope(
            onWillPop: () async {
              print('back pressed');
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Text(
                        'Do you want to discard?',
                        style: GoogleFonts.getFont(
                          'Fira Sans',
                          fontSize: 20.0,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      elevation: 8.0,
                      actions: [
                        // yes button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              back = true;
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Yes',
                            style: GoogleFonts.getFont(
                              'Fira Sans',
                              fontSize: 18.0,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // no button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              back = false;
                            });
                          },
                          child: Text(
                            'No',
                            style: GoogleFonts.getFont(
                              'Fira Sans',
                              fontSize: 18.0,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
              print('back: $back');
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25.0),
                  ),
                ),
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: GestureDetector(
                    onTap: () {
                      // _renamePdfDialog();
                    },
                    child: AutoSizeText(
                      widget.pdfName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.getFont(
                        'Fira Sans',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await _createPdfFile();
                      await _savePdfFile();
                    },
                    icon: Icon(MaterialCommunityIcons.file_pdf),
                  ),
                ],
              ),
              body: DragAndDropGridView(
                padding: EdgeInsets.all(5.0),
                onWillAccept: (oldIndex, newIndex) {
                  images = [...tmpList];
                  int indexOfFirstItem = images.indexOf(images[oldIndex]);
                  int indexOfSecondItem = images.indexOf(images[newIndex]);
                  /*if (indexOfFirstItem > indexOfSecondItem) {
                    for (int i = images.indexOf(images[oldIndex]);
                        i > images.indexOf(images[newIndex]);
                        i--) {
                      var tmp = images[i - 1];
                      images[i - 1] = images[i];
                      images[i] = tmp;
                    }
                  } else {
                    for (int i = images.indexOf(images[oldIndex]);
                        i < images.indexOf(images[newIndex]);
                        i++) {
                      var tmp = images[i + 1];
                      images[i + 1] = images[i];
                      images[i] = tmp;
                    }
                  }*/
                  var tmp = images[indexOfFirstItem];
                  images[indexOfFirstItem] = images[indexOfSecondItem];
                  images[indexOfSecondItem] = tmp;
                  setState(
                    () {
                      pos = newIndex;
                    },
                  );
                  return true;
                },
                onReorder: (oldIndex, newIndex) {
                  images = [...tmpList];
                  int indexOfFirstItem = images.indexOf(images[oldIndex]);
                  int indexOfSecondItem = images.indexOf(images[newIndex]);
                  /*if (indexOfFirstItem > indexOfSecondItem) {
                    for (int i = images.indexOf(images[oldIndex]);
                        i > images.indexOf(images[newIndex]);
                        i--) {
                      var tmp = images[i - 1];
                      images[i - 1] = images[i];
                      images[i] = tmp;
                    }
                  } else {
                    for (int i = images.indexOf(images[oldIndex]);
                        i < images.indexOf(images[newIndex]);
                        i++) {
                      var tmp = images[i + 1];
                      images[i + 1] = images[i];
                      images[i] = tmp;
                    }
                  }*/
                  var tmp = images[indexOfFirstItem];
                  images[indexOfFirstItem] = images[indexOfSecondItem];
                  images[indexOfSecondItem] = tmp;
                  tmpList = [...images];
                  setState(
                    () {
                      pos = null;
                    },
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4.5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Opacity(
                    opacity: pos != null
                        ? pos == index
                            ? 0.6
                            : 1
                        : 1,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            print('fullScreenImage');
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => PDFImageItem(
                                  pdfName: widget.pdfName,
                                  image: images[index],
                                  pdfImages: images,
                                  index: index,
                                  pdfCreationDate: widget.pdfCreationDate,
                                  timestamp: widget.timestamp,
                                ),
                              ),
                            )
                                .then((value) {
                              setState(() {
                                images;
                              });
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Colors.black87,
                            ),
                            child: LayoutBuilder(builder: (context, costrains) {
                              if (variableSet == 0) {
                                height = costrains.maxHeight;
                                width = costrains.maxWidth;
                                variableSet++;
                              }
                              return GridTile(
                                child: Image.file(
                                  images[index],
                                  fit: BoxFit.cover,
                                  height: height,
                                  width: width,
                                ),
                              );
                            }),
                          ),
                        ),
                        // index
                        Visibility(
                          visible: pos == null,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.getFont(
                                  'Fira Sans',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // delete button
                        Visibility(
                          visible: pos == null,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () {
                                  customAlertDialog(
                                      context,
                                      'Warning!',
                                      'Do you want to delete this image?',
                                      () => {
                                            print('remove $index'),
                                            setState(() {
                                              images.removeAt(index);
                                            }),
                                            Navigator.of(context).canPop()
                                                ? Navigator.of(context).pop()
                                                : null,
                                            print(images.length),
                                          });
                                },
                                child: Icon(
                                  MaterialIcons.delete,
                                  color: Colors.redAccent.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: images.length,
              ),
              floatingActionButton: _buildFloatingActionButton(context),
            ),
          );
  }
}
