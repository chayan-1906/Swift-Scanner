import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swift_scanner/services/global_methods.dart';

import '../bottom_bar_screen.dart';

class PhoneAuthentication {
  String phoneNo = '';
  String smsCode = '';
  String verificationId = '';
  final _formKey = GlobalKey<FormState>();

  TextStyle? createStyle(BuildContext context, Color color) {
    ThemeData theme = Theme.of(context);
    return theme.textTheme.headline3?.copyWith(color: color);
  }

  showBottomSheetPhoneNumber(BuildContext context) {
    return showMaterialModalBottomSheet(
      context: context,
      elevation: 8.0,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            child: Column(
              children: [
                Card(
                  elevation: 8.0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: // textformfield phone number
                        Column(
                      children: [
                        // phone no textfield
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            key: const ValueKey('phone'),
                            validator: (phone) {
                              if (phone!.isEmpty) {
                                return 'Please enter your phone number';
                              } else if (phone.length != 10) {
                                return 'Please enter a valid phone number';
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              hintText: 'Enter your phone number...',
                              hintStyle: GoogleFonts.getFont(
                                'Fira Sans',
                                fontSize: 16.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              errorStyle: GoogleFonts.getFont(
                                'Fira Sans',
                                fontSize: 16.0,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              prefixIcon: Icon(MaterialIcons.phone_android),
                              fillColor: Theme.of(context).backgroundColor,
                            ),
                            onSaved: (value) {
                              phoneNo = '+91$value';
                            },
                          ),
                        ),
                        // send otp button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                _submitForm(context);
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 15.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                height: 36.0,
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
                                      MaterialCommunityIcons.message_text,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 5.0),
                                    Text(
                                      'Send OTP',
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
                            const SizedBox(width: 12.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        verifyPhone(context).then((value) {
          Navigator.of(context).pop(); // pop out phone no. bottom sheet
          showBottomSheetOTP(context);
        });
      } catch (error) {
        GlobalMethods.authErrorDialog(
          context,
          'Error Occurred',
          error.toString(),
        );
        print('error occurred: ${error.toString()}');
      }
    }
  }

  Future<void> verifyPhone(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNo,
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
      codeSent: (String verId, int? forceResendingToken) {
        verificationId = verId;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'Code Sent',
        //       style: GoogleFonts.getFont(
        //         'Fira Sans',
        //         fontSize: 16.0,
        //         color: Colors.black,
        //         fontWeight: FontWeight.w700,
        //       ),
        //     ),
        //     backgroundColor: Colors.greenAccent,
        //     duration: Duration(seconds: 2),
        //     elevation: 8.0,
        //     action: SnackBarAction(
        //         label: 'Okay',
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         }),
        //   ),
        // );
      },
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
        print('verified');
        SnackBar(
          content: Text(
            'Phone no. verified',
            style: GoogleFonts.getFont(
              'Fira Sans',
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
          elevation: 8.0,
          action: SnackBarAction(
              label: 'Okay',
              onPressed: () {
                Navigator.of(context).pop();
              }),
        );
      },
      verificationFailed: (FirebaseAuthException error) {
        print('Exception: $error');
        SnackBar(
          content: Text(
            'Error: $error',
            style: GoogleFonts.getFont(
              'Fira Sans',
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
          elevation: 8.0,
        );
      },
      timeout: const Duration(seconds: 60),
    );
  }

  showBottomSheetOTP(BuildContext context) {
    return showMaterialModalBottomSheet(
      context: context,
      elevation: 8.0,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10.0),
                GradientText(
                  'Enter OTP',
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent,
                      Colors.blueAccent,
                      Colors.yellowAccent,
                      Colors.redAccent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  style: GoogleFonts.getFont(
                    'Fira Sans',
                    fontSize: 25.0,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                OtpTextField(
                  numberOfFields: 6,
                  styles: [
                    createStyle(context, Colors.pinkAccent),
                    createStyle(context, Colors.lightBlueAccent),
                    createStyle(context, Colors.orangeAccent),
                    createStyle(context, Colors.redAccent),
                    createStyle(context, Colors.pinkAccent),
                    createStyle(context, Colors.lightBlueAccent),
                  ],
                  showFieldAsBox: false,
                  onCodeChanged: (String code) {
                    smsCode += code;
                  },
                  onSubmit: (String verificationCode) {
                    print('onSubmit');
                    phoneAuth(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> phoneAuth(BuildContext context) async {
    print('phoneAuth called');
    print('verificationId: $verificationId');
    print('smsCode: $smsCode');
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    print('signing in');
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      Navigator.of(context).pop(); // pop out otp bottom sheet
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: BottomBarScreen(),
        ),
      );
      storeNewUser(FirebaseAuth.instance.currentUser!, context);
    }).catchError((onError) {
      print('Error: $onError');
    });
  }

  storeNewUser(User user, BuildContext context) {
    print('storeNewUser');
    User? currentUser = FirebaseAuth.instance.currentUser;
    var createdDate = user.metadata.creationTime.toString();
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = '${dateParse.day}-${dateParse.month}-${dateParse.year}';
    FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
      'id': currentUser.uid,
      'name': currentUser.displayName,
      'email': currentUser.email ?? '',
      'phoneNumber': phoneNo,
      'imageUrl': '',
      'joinedAt': formattedDate,
      'createdAt': createdDate,
      'authenticatedBy': 'phone',
    }).then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/homepage');
    }).catchError((onError) {
      print('Error: $onError');
    });
  }
}
