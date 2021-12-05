import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidget;
import 'package:progress_dialog/progress_dialog.dart';

import 'bottom_bar_screen.dart';
import 'pdf_image_item.dart';

class ScanIdCardScreen extends StatefulWidget {
  final String idCardName;
  final List idCardImages;
  final String pdfCreationDate;
  final Timestamp timestamp;

  const ScanIdCardScreen({
    Key? key,
    required this.idCardImages,
    required this.idCardName,
    required this.pdfCreationDate,
    required this.timestamp,
  }) : super(key: key);

  @override
  _ScanIdCardScreenState createState() => _ScanIdCardScreenState();
}

class _ScanIdCardScreenState extends State<ScanIdCardScreen> {
  bool back = false;
  String _idCardUrl = '';
  var pdf = pdfWidget.Document();
  ProgressDialog? progressDialog;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  _createIdCard() async {
    for (var img in widget.idCardImages) {
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

  _saveIdCard() async {
    try {
      final dir = await getExternalStorageDirectory();
      final pdfFile = File('${dir!.path}/${widget.idCardName}.pdf');
      await pdfFile.writeAsBytes(await pdf.save());
      // id card saved snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent.shade100,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: AutoSizeText(
              'ID Card Saved in ${dir.path}',
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
          .child('idCards')
          .child(widget.idCardName)
          .child('${widget.idCardName}.pdf');
      print('Uploading in storage...!');
      await progressDialog!.show();
      await storageReference.putFile(pdfFile).then((p0) async {
        _idCardUrl = await storageReference.getDownloadURL();
        print('Uploaded in storage...!');
        print('Uploading in firestore...!');
        await _firebaseFirestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('pdfs')
            .doc(widget.pdfCreationDate)
            .set({
          'pdfUrl': _idCardUrl,
          'pdfName': widget.idCardName,
          'pdfActualName': widget.idCardName,
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
                  'ID Card uploaded successfully!',
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
      print('saved in ${dir.path}/${widget.idCardName}.pdf');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return WillPopScope(
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
                widget.idCardName,
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
                await _createIdCard();
                await _saveIdCard();
              },
              icon: Icon(MaterialIcons.done),
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // 1st image
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    print('fullScreenImage');
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => PDFImageItem(
                          pdfName: widget.idCardName,
                          image: widget.idCardImages[0],
                          pdfImages: widget.idCardImages,
                          index: 0,
                          pdfCreationDate: '',
                          timestamp: widget.timestamp,
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {
                        widget.idCardImages;
                      });
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      // color: Colors.redAccent,
                      image: DecorationImage(
                        image: FileImage(widget.idCardImages[0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              // 2nd image
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    print('fullScreenImage');
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => PDFImageItem(
                          pdfName: widget.idCardName,
                          image: widget.idCardImages[1],
                          pdfImages: widget.idCardImages,
                          index: 1,
                          pdfCreationDate: '',
                          timestamp: Timestamp.now(),
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {
                        widget.idCardImages;
                      });
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      // color: Colors.blueAccent,
                      image: DecorationImage(
                        image: FileImage(widget.idCardImages[1]),
                        fit: BoxFit.cover,
                      ),
                    ),
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
