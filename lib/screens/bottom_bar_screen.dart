import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swift_scanner/widgets/home_screen_widgets.dart';

import 'bottom_bar_screens/all_docs_screen.dart';
import 'bottom_bar_screens/home_screen.dart';

class BottomBarScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const BottomBarScreen({Key? key}) : super(key: key);

  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<dynamic>? pages;
  var _bottomNavIndex = 0;

  final iconList = <IconData>[
    MaterialCommunityIcons.home_thermometer,
    MaterialCommunityIcons.file_document_box,
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      const HomeScreen(),
      const AllDocsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      /*appBar: AppBar(
        title: Text('Swift Scanner'),
        actions: [
          Visibility(
            visible: FirebaseAuth.instance.currentUser != null ? true : false,
            child: InkWell(
              onTap: () async {
                GlobalMethods.signOutDialog(
                    context, 'Logout', 'Do you want to logout?', () async {
                  await _firebaseAuth.signOut();
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Icon(MaterialCommunityIcons.power),
              ),
            ),
          ),
        ],
      ),*/
      body: DoubleBackToCloseApp(
        child: pages![_bottomNavIndex],
        snackBar: SnackBar(
          content: Text(
            'Tap again to exit',
            style: GoogleFonts.getFont(
              'Fira Sans',
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.black,
        ),
      ),
      floatingActionButton: SpeedDialFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        elevation: 8.0,
        icons: iconList,
        // backgroundColor: Colors.redAccent,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        leftCornerRadius: 20.0,
        rightCornerRadius: 20.0,
        splashColor: Colors.blueAccent.shade100,
        activeColor: Colors.blueAccent.shade100,
        inactiveColor: Colors.grey,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}
