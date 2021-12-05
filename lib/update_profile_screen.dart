import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'services/global_methods.dart';
import 'widgets/loading.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User user;
  final DocumentSnapshot documentSnapshot;
  const UpdateProfileScreen({
    Key? key,
    required this.user,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  File? _pickedImage;
  String _name = '';
  String _emailAddress = '';
  String _phoneNumber = '';
  String _imageUrl = '';
  bool _isLoading = false;
  bool _showSave = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = '${dateParse.day}-${dateParse.month}-${dateParse.year}';
    if (isValid) {
      _formKey.currentState!.save();
      try {
        if (_pickedImage == null) {
          GlobalMethods.authErrorDialog(
            context,
            'Warning!',
            'Please pick an image',
          );
          return;
        } else {
          setState(() {
            _isLoading = true;
          });
          final User user = _firebaseAuth.currentUser!;
          final _uid = user.uid;
          final storageReference = FirebaseStorage.instance
              .ref()
              .child('profilePictures')
              .child(_uid + ".jpg");
          await storageReference.putFile(_pickedImage!);
          _imageUrl = await storageReference.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_uid)
              .update({
            'id': _uid,
            'name': _nameController.text,
            'email': _emailController.text,
            'phoneNumber': _phoneController.text,
            'imageUrl': _imageUrl,
          });
          Navigator.canPop(context) ? Navigator.pop(context) : null;
          // Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      } catch (error) {
        GlobalMethods.authErrorDialog(
          context,
          'Error Occurred',
          error.toString(),
        );
        print('error occurred: ${error.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _pickImageCamera() async {
    final _imagePicker = ImagePicker();
    var pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
      _showSave = true;
    });
  }

  void _pickImageGallery() async {
    final _imagePicker = ImagePicker();
    var pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (pickedImage != null) {
      final pickedImageFile = File(pickedImage.path);
      setState(() {
        _pickedImage = pickedImageFile;
        _showSave = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(false);
        return Future.value(false);
      },
      child: _isLoading
          ? const Loading()
          : Scaffold(
              key: _scaffoldStateKey,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.white,
                title: Text(
                  'Update Profile',
                  style: GoogleFonts.getFont(
                    'Fira Sans',
                    color: Color(0xFF1DB9C3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    MaterialCommunityIcons.close,
                    color: Color(0xFF1DB9C3),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                actions: [
                  Visibility(
                    visible: _showSave,
                    child: IconButton(
                      onPressed: () {
                        _submitForm();
                      },
                      icon: Icon(
                        MaterialIcons.done,
                        color: Color(0xFF1DB9C3),
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  color: Colors.white,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 10.0),
                        // profile picture
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Choose Image Picker',
                                      style: GoogleFonts.getFont(
                                        'Roboto Slab',
                                        fontSize: 20.0,
                                        color: Theme.of(context).primaryColor,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                      // alert dialog
                                      child: ListBody(
                                        children: [
                                          // camera
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _pickImageCamera();
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    MaterialCommunityIcons
                                                        .camera,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  'Camera',
                                                  style: GoogleFonts.getFont(
                                                    'Roboto Slab',
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // gallery
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _pickImageGallery();
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    MaterialCommunityIcons
                                                        .image,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  'Gallery',
                                                  style: GoogleFonts.getFont(
                                                    'Roboto Slab',
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 100.0,
                            child: _pickedImage == null
                                ? Image.network(
                                    widget.documentSnapshot.get('imageUrl') ==
                                            ''
                                        ? 'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg'
                                        : widget.documentSnapshot
                                            .get('imageUrl'),
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(_pickedImage!),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        // textformfield name
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            controller: _nameController,
                            key: const ValueKey('name'),
                            validator: (name) {
                              if (name!.isEmpty) {
                                return 'Please enter your name';
                              } else {
                                return null;
                              }
                            },
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              labelText: 'Name',
                              labelStyle: GoogleFonts.getFont(
                                'Fira Sans',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                // color: Theme.of(context).primaryColorDark,
                              ),
                              hintText: 'Enter your name...',
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
                              prefixIcon: Icon(MaterialIcons.person),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _showSave = true;
                              });
                            },
                            onSaved: (value) {
                              _name = value!;
                              setState(() {
                                _showSave = true;
                              });
                            },
                          ),
                        ),
                        // textformfield email --> if authenticated by phone
                        Visibility(
                          visible: !(widget.documentSnapshot
                                      .get('authenticatedBy') ==
                                  'email' ||
                              widget.documentSnapshot.get('authenticatedBy') ==
                                  'google'),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _emailController,
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
                                prefixIcon: Icon(MaterialCommunityIcons.email),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _showSave = true;
                                });
                              },
                              onSaved: (value) {
                                _emailAddress = value!;
                                setState(() {
                                  _showSave = true;
                                });
                              },
                            ),
                          ),
                        ),
                        // textformfield phone number --> if not authenticated by phone
                        Visibility(
                          visible: !(widget.documentSnapshot
                                  .get('authenticatedBy') ==
                              'phone'),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _phoneController,
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
                                      color:
                                          Theme.of(context).primaryColorDark),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                filled: true,
                                labelText: 'Phone Number',
                                labelStyle: GoogleFonts.getFont(
                                  'Fira Sans',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  borderSide:
                                      BorderSide(color: Colors.redAccent),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: Icon(MaterialIcons.phone_android),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _showSave = true;
                                });
                              },
                              onSaved: (value) {
                                _phoneNumber = value!;
                                setState(() {
                                  _showSave = true;
                                });
                              },
                              onEditingComplete: _submitForm,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
