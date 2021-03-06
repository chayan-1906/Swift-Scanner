import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swift_scanner/screens/auth/forgot_password_screen.dart';
import 'package:swift_scanner/services/global_methods.dart';
import 'package:swift_scanner/widgets/loading.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _emailAddress = '';
  String _password = '';
  bool _obscureText = true;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        await _firebaseAuth
            .signInWithEmailAndPassword(
              email: _emailAddress.toLowerCase().trim(),
              password: _password.trim(),
            )
            .then((value) =>
                Navigator.canPop(context) ? Navigator.pop(context) : null);
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: Loading(),
            ),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.95,
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: WaveWidget(
                        config: CustomConfig(
                          gradients: [
                            [
                              Colors.pinkAccent.withOpacity(0.6),
                              Colors.pinkAccent.withOpacity(0.3),
                            ],
                            [
                              Colors.blueAccent.withOpacity(0.6),
                              Colors.blueAccent.withOpacity(0.3),
                            ],
                            [
                              Colors.greenAccent.withOpacity(0.6),
                              Colors.greenAccent.withOpacity(0.3),
                            ],
                          ],
                          durations: [4000, 5000, 7000],
                          heightPercentages: [0.01, 0.10, 0.15],
                          blur: const MaskFilter.blur(BlurStyle.normal, 10.0),
                          gradientBegin: Alignment.bottomLeft,
                          gradientEnd: Alignment.topRight,
                        ),
                        waveAmplitude: 0,
                        waveFrequency: 2,
                        size: const Size(double.infinity, double.infinity),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 80.0),
                        height: 120.0,
                        width: 120.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/landing_page.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // textformfield email
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('email'),
                                validator: (email) {
                                  if (email!.isEmpty || !email.contains('@')) {
                                    return 'Please enter your email';
                                  } else {
                                    return null;
                                  }
                                },
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                focusNode: _emailFocusNode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  labelText: 'Email',
                                  labelStyle: GoogleFonts.getFont(
                                    'Fira Sans',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  hintText: 'Enter your email...',
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
                                    borderSide:
                                        BorderSide(color: Colors.redAccent),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  prefixIcon:
                                      Icon(MaterialCommunityIcons.email),
                                  fillColor: Theme.of(context).backgroundColor,
                                ),
                                onSaved: (value) {
                                  _emailAddress = value!;
                                },
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode),
                              ),
                            ),
                            // textformfield password
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                key: const ValueKey('password'),
                                validator: (password) {
                                  if (password!.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (password.length < 6) {
                                    return 'Password should contain at least 6 characters';
                                  } else {
                                    return null;
                                  }
                                },
                                keyboardType: TextInputType.name,
                                focusNode: _passwordFocusNode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  labelText: 'Password',
                                  labelStyle: GoogleFonts.getFont(
                                    'Fira Sans',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  hintText: 'Enter your password...',
                                  hintStyle: GoogleFonts.getFont(
                                    'Fira Sans',
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  errorStyle: GoogleFonts.getFont(
                                    'Fira Sans',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.redAccent,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.redAccent),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  prefixIcon: Icon(MaterialIcons.security),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: _obscureText
                                        ? Icon(MaterialIcons.visibility)
                                        : Icon(MaterialIcons.visibility_off),
                                  ),
                                  fillColor: Theme.of(context).backgroundColor,
                                ),
                                obscureText: _obscureText,
                                onSaved: (value) {
                                  _password = value!;
                                },
                              ),
                            ),
                            // login button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _submitForm();
                                  },
                                  child: _isLoading
                                      ? const Loading()
                                      : Container(
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
                                            borderRadius:
                                                BorderRadius.circular(12.0),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                const SizedBox(width: 12.0),
                              ],
                            ),
                            // forget password
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.topToBottom,
                                        child: ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forget Password',
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.getFont(
                                      'Fira Sans',
                                      fontSize: 15.0,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFF141E61),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
