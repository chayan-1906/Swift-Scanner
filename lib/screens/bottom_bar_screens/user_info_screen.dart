import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:swift_scanner/provider/theme_provider.dart';
import 'package:swift_scanner/services/global_methods.dart';
import 'package:swift_scanner/widgets/custom_list_tile.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  DocumentSnapshot<Map<String, dynamic>>? documentSnapshot;
  User? user;
  String _uid = '';
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String _joinedAt = '';
  String _userImageUrl = '';
  String authenticatedBy = '';

  void getUserInfo() async {
    user = _firebaseAuth.currentUser;
    _uid = user!.uid;
    print(user!.email);
    if (user!.isAnonymous) {
      // for anonymous users
      _name = 'Guest';
      _email = 'Anonymous';
      _phoneNumber = 'Not Available';
      _joinedAt = 'Not Available';
      _userImageUrl = '';
      authenticatedBy = 'anonymous';
      return;
    }
    documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    print('documentSnapshot: ${documentSnapshot}');
    // for authenticated users
    setState(() {
      _name = documentSnapshot!.get('name') ?? '';
      _email = documentSnapshot!.get('email') ?? 'Not Available';
      _phoneNumber = documentSnapshot!.get('phoneNumber') ?? '';
      _joinedAt = documentSnapshot!.get('joinedAt');
      _userImageUrl = documentSnapshot!.get('imageUrl') ??
          'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg';
      authenticatedBy = documentSnapshot!.get('authenticatedBy');
      print(user!.photoURL);
      print(user!.displayName);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // profile picture
                  Container(
                    height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(60.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5.0,
                          offset: Offset(5.0, 8.0),
                          color: Colors.black38,
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(
                          _userImageUrl != ''
                              ? _userImageUrl
                              : 'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  // Name, Phone No.
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Visibility(
                          visible: _name != '',
                          child: AutoSizeText(
                            _name,
                            maxLines: 1,
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              'Fira Sans',
                              fontSize: 20.0,
                              // color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        // Phone No.
                        Visibility(
                          visible: _phoneNumber != '',
                          child: AutoSizeText(
                            _phoneNumber,
                            maxLines: 1,
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              'Fira Sans',
                              fontSize: 16.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        // Edit Button
                        /*Visibility(
                          visible: !user!.isAnonymous,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(
                                    color: Colors.redAccent.shade200),
                              ),
                            ),
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Icon(
                                Icons.edit_rounded,
                                color: Colors.redAccent.shade200,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: UpdateProfileScreen(
                                    user: user!,
                                    documentSnapshot: documentSnapshot!,
                                  ),
                                ),
                              );
                            },
                            label: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                'Edit',
                                style: GoogleFonts.getFont(
                                  'Noto Serif',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent.shade200,
                                ),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              // Account
              Text(
                'Account',
                style: GoogleFonts.getFont(
                  'Charmonman',
                  fontSize: 30.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Account --> CustomListTile()
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomListTile(
                    icon: Icons.email,
                    title: 'Email',
                    subTitle: _email,
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.blueGrey,
                  ),
                  CustomListTile(
                    icon: Icons.watch_later,
                    title: 'Joined Date',
                    subTitle: _joinedAt,
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              // User Settings
              // Text(
              //   'User Settings',
              //   style: GoogleFonts.getFont(
              //     'Charmonman',
              //     fontSize: 30.0,
              //     letterSpacing: 2.0,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // User Settings --> CustomListTile()
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // light-dark theme
                  /*ListTileSwitch(
                      value: themeProvider.darkTheme,
                      leading: Icon(MaterialCommunityIcons.theme_light_dark),
                      onChanged: (value) {
                        setState(() {
                          themeProvider.darkTheme = value;
                        });
                      },
                      visualDensity: VisualDensity.comfortable,
                      switchType: SwitchType.cupertino,
                      switchActiveColor: Colors.indigoAccent,
                      title: AutoSizeText(
                        'Dark Theme',
                        maxLines: 1,
                        textScaleFactor: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.getFont(
                          'Fira Sans',
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Divider(
                      height: 10.0,
                      color: Colors.blueGrey,
                    ),*/
                  // logout
                  GestureDetector(
                    onTap: () async {
                      GlobalMethods.signOutDialog(
                          context, 'Sign Out', 'Do you want to sign out?',
                          () async {
                        Navigator.of(context).pop();
                        await _firebaseAuth.signOut();
                      });
                    },
                    child: CustomListTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      subTitle: '',
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
