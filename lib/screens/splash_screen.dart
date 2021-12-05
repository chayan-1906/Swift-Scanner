import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swift_scanner/screens/user_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const colorizeColors = [
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellowAccent,
    Colors.redAccent,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), navigateToUserState);
  }

  void navigateToUserState() {
    Navigator.pushReplacementNamed(context, UserState.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Swift Scanner',
                  textAlign: TextAlign.center,
                  textStyle: GoogleFonts.getFont(
                    'Kaushan Script',
                    fontSize: 45.0,
                    letterSpacing: 1.2,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700,
                  ),
                  colors: colorizeColors,
                ),
              ],
              repeatForever: true,
              pause: const Duration(milliseconds: 0),
            ),
          ),
        ],
      ),
    );
  }
}
