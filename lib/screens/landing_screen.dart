import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swift_scanner/services/global_methods.dart';

import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = '/landing_screen';

  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _googleSignIn() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        try {
          final authResult = await FirebaseAuth.instance.signInWithCredential(
            GoogleAuthProvider.credential(
              idToken: googleAuth.idToken,
              accessToken: googleAuth.accessToken,
            ),
          );
          var date = authResult.user!.metadata.creationTime.toString();
          var dateParse = DateTime.parse(date);
          var createdDate = authResult.user!.metadata.creationTime.toString();
          var formattedDate =
              '${dateParse.day}-${dateParse.month}-${dateParse.year}';
          String _uid = authResult.user!.uid;
          await FirebaseFirestore.instance.collection('users').doc(_uid).set({
            'id': _uid,
            'name': authResult.user!.displayName ?? '',
            'email': authResult.user!.email,
            'phoneNumber': authResult.user!.phoneNumber,
            'imageUrl': authResult.user!.photoURL,
            'joinedAt': formattedDate,
            'createdAt': createdDate,
            'authenticatedBy': 'google',
          });
          print(authResult.user!.phoneNumber);
        } catch (error) {
          GlobalMethods.authErrorDialog(
            context,
            'Error Occurred',
            error.toString(),
          );
          print('error occurred ${error.toString()}');
        }
      }
    }
  }

  Future<void> _loginAnonymously() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _firebaseAuth.signInAnonymously();
    } catch (error) {
      GlobalMethods.authErrorDialog(
        context,
        'Error Occurred',
        error.toString(),
      );
      print('error occurred ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/landing_page.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // above image
          // anonymous sign in
          Positioned(
            top: 50.0,
            right: 10.0,
            child: GestureDetector(
              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   PageTransition(
                //     type: PageTransitionType.fade,
                //     child: BottomBarScreen(),
                //   ),
                // );
                _loginAnonymously();
              },
              child: GradientText(
                'Anonymous',
                style: GoogleFonts.getFont(
                  'Caveat',
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            // color: Colors.lightBlueAccent,
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            width: double.infinity,
            // welcome, welcome to swift scanner, sign in & sign up
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // welcome
                GradientText(
                  'Welcome',
                  style: GoogleFonts.getFont(
                    'Cookie',
                    fontSize: 70.0,
                    letterSpacing: 5.0,
                    fontWeight: FontWeight.w700,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.pinkAccent,
                      Colors.blueAccent,
                      Colors.yellowAccent,
                      Colors.redAccent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                const SizedBox(height: 20.0),
                // welcome to swift scanner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Welcome to \nSwift Scanner',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(
                      'Satisfy',
                      fontSize: 45.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                // login, sign up, or continue with google+
                Column(
                  children: [
                    // login, sign up
                    Row(
                      children: [
                        const SizedBox(width: 10.0),
                        // login
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Navigator.of(context)
                              //     .pushNamed(LoginScreen.routeName);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.topToBottom,
                                  child: LoginScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 45.0,
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
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.5),
                                    blurRadius: 1.5,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Feather.user_check,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.getFont(
                                      'Fira Sans',
                                      fontSize: 20.0,
                                      color: Colors.black87,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // sign up
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Navigator.of(context)
                              //     .pushNamed(SignUpScreen.routeName);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.topToBottom,
                                  child: SignUpScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 45.0,
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
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.5),
                                    blurRadius: 1.5,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Feather.user_plus,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'Sign Up',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.getFont(
                                      'Fira Sans',
                                      fontSize: 20.0,
                                      color: Colors.black87,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    // or continue with
                    /*Row(
                      children: [
                        // divider
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                          ),
                        ),
                        // or continue with
                        Text(
                          'or continue with',
                          style: GoogleFonts.getFont(
                            'Fira Sans',
                            fontSize: 20.0,
                            color: Colors.black,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // divider
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    // Google+ & Phone
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Google+
                        SizedBox(
                          height: 45.0,
                          child: OutlinedButton.icon(
                            icon: Icon(
                              MaterialCommunityIcons.google_plus_box,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              _googleSignIn();
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              side: BorderSide(
                                  width: 2.0, color: Colors.redAccent),
                              elevation: 5.0,
                            ),
                            label: Text(
                              'Google+',
                              style: GoogleFonts.getFont(
                                'Fira Sans',
                                fontSize: 20.0,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Phone
                        SizedBox(
                          height: 45.0,
                          child: OutlinedButton.icon(
                            icon: Icon(
                              MaterialCommunityIcons.cellphone_message,
                              color: Colors.amberAccent,
                            ),
                            onPressed: () {
                              PhoneAuthentication()
                                  .showBottomSheetPhoneNumber(context);
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              side: BorderSide(
                                  width: 2.0, color: Colors.amberAccent),
                              elevation: 5.0,
                            ),
                            label: Text(
                              'Phone',
                              style: GoogleFonts.getFont(
                                'Fira Sans',
                                fontSize: 20.0,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),*/
                    const SizedBox(height: 10.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
