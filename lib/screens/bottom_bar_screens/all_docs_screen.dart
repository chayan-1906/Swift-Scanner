import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swift_scanner/widgets/home_screen_widgets.dart';

class AllDocsScreen extends StatefulWidget {
  const AllDocsScreen({Key? key}) : super(key: key);

  @override
  _AllDocsScreenState createState() => _AllDocsScreenState();
}

class _AllDocsScreenState extends State<AllDocsScreen> {
  int _noOfPdfs = 0;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  static const colorizeColors = [
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellowAccent,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
                // height: MediaQuery.of(context).size.height / 8,
                // color: Colors.yellowAccent,
                child: TextFormField(
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
            SizedBox(height: 15.0),
            // all docs
            StreamBuilder(
                stream: _firebaseAuth.currentUser != null
                    ? _firebaseFirestore
                        .collection('users')
                        .doc('${_firebaseAuth.currentUser!.uid}')
                        .collection('pdfs')
                        .snapshots()
                    : null,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      _noOfPdfs = snapshot.data!.docs.length;
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0, left: 10.0, right: 10.0),
                        child: Text(
                          'All Docs ($_noOfPdfs)',
                          style: GoogleFonts.getFont(
                            'Fira Sans',
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                  } else {
                    _noOfPdfs = 0;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 20.0),
                    child: Visibility(
                      visible: _firebaseAuth.currentUser != null,
                      child: Text(
                        'All Docs ($_noOfPdfs)',
                        style: GoogleFonts.getFont(
                          'Fira Sans',
                          fontSize: 25.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
            // listview
            Flexible(
              child: PDFItem(),
            ),
          ],
        ),
      ),
    );
  }
}
