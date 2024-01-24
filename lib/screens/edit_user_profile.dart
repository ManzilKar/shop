import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selfcheckoutapp/constants.dart';
import 'package:selfcheckoutapp/services/firebase_services.dart';
import 'package:selfcheckoutapp/services/shared_pref_service.dart';
import 'package:selfcheckoutapp/widgets/custom_button.dart';
import 'package:selfcheckoutapp/widgets/custom_input.dart';
import 'package:selfcheckoutapp/widgets/profile_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditUserProfile extends StatefulWidget {
  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  FirebaseServices _firebaseServices = FirebaseServices();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  String? profilePath;
  File? _image;
  File? image;
  var loading = false;

  final storage = FirebaseStorage.instance;

  Future _updateProfileDetail(String uid) async {
    setState(() {
      loading = true;
    });
    uploadImage().then((value) async => {
          await FirebaseFirestore.instance
              .collection("UserDetails")
              .doc(_firebaseServices.getUserId())
              .update({
            "firstName": _firstName.text,
            "LastName": _lastName.text,
            "Address": _address.text,
            "PhoneNumber": _phoneNumber.text,
            "profileImage": value ?? profilePath
          }),
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Profile updated successfully."))),
          Navigator.pop(context)
        });
  }

  Future _fetchProfileDetail() async {
    await FirebaseFirestore.instance
        .collection("UserDetails")
        .doc(_firebaseServices.getUserId())
        .get()
        .then((value) {
      profilePath = value["profileImage"];
      _firstName.text = value["firstName"];
      _lastName.text = value["LastName"];
      _address.text = value["Address"];
      _phoneNumber.text = value["PhoneNumber"];
    });
    setState(() {});
  }

  @override
  void initState() {
    _fetchProfileDetail();
    super.initState();
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      _image = File(image.path);
      setState(() => this.image = _image);
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future uploadImage() async {
    if (image == null) {
      return;
    }
    final reference = storage
        .ref()
        .child('${DateTime.now()}${_firebaseServices.getUserId()}');
    final uploadTask = reference.putFile(image!);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    profilePath = downloadUrl;
    print('Download URL: $downloadUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: Constants.boldHeadingAppBar,
        ),
        leading: Icon(Icons.edit),
        backgroundColor: Colors.blue,
        toolbarHeight: 80.0,
        elevation: 0.0,
        toolbarTextStyle: GoogleFonts.poppinsTextTheme().bodyMedium,
        titleTextStyle: GoogleFonts.poppinsTextTheme().titleLarge,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.blue,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                child: SizedBox(
                  height: 115,
                  width: 115,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      if (profilePath != null)
                        Avatar(
                          url: profilePath,
                          imagePath: image,
                        ),
                      Positioned(
                        right: -10,
                        bottom: 0,
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  color: Color(0xfff5f6f9)),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  await pickImage();
                                },
                                icon: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Color(0xff9a9a9c),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(),
              Text("First Name"),
              CustomInput(
                controller: _firstName,
                hintText: "Edit First Name...",
                textInputType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
              ),
              Text("Last Name"),
              CustomInput(
                controller: _lastName,
                hintText: "Edit Last Name...",
                textInputType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
              ),
              Text("Address"),
              CustomInput(
                controller: _address,
                hintText: "Edit Address ...",
                textInputType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
              ),
              Text("Phone Number"),
              CustomInput(
                controller: _phoneNumber,
                hintText: "Edit Phone Number ...",
                textInputType: TextInputType.number,
                textCapitalization: TextCapitalization.words,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomEditBtn(
                    text: "Cancel",
                    onPressed: () {
                      FocusScope.of(context).requestFocus(
                          FocusNode()); //CLOSING THE KEYBOARD BEFORE GOING TO NEXT PAGE
                      Navigator.pop(context);
                    },
                    outlineBtn: true,
                  ),
                  CustomEditBtn(
                      isLoading: loading,
                      text: "Save",
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(
                            FocusNode()); //CLOSING THE KEYBOARD BEFORE GOING TO NEXT PAGE
                        //  _addDisplayName()
                        await SharedPref.sharePref
                            .readSecureData("userDetailUid")
                            .then((value) {
                          debugPrint("Value in update" + value);
                          _updateProfileDetail(value);
                        });
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
