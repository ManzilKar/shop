import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selfcheckoutapp/constants.dart';
import 'package:selfcheckoutapp/screens/login.dart';
import 'package:selfcheckoutapp/services/firebase_services.dart';
import 'package:selfcheckoutapp/services/shared_pref_service.dart';
import 'package:selfcheckoutapp/services/user_detail.dart';
import 'package:selfcheckoutapp/widgets/custom_button.dart';
import 'package:selfcheckoutapp/widgets/custom_input.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //ALERT DIALOG TO DISPLAY ERRORS
  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Container(
              child: Text(error),
            ),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  //FORM INPUT VALUES
  String _firstName = "";
  String _lastName = "";
  String _registerEmail = "";
  String _registerPassword = "";
  String _confirmPassword = "";
  String _phoneNumber = "";
  String _address = "";

  //CREATE A NEW ACCOUNT
  Future<String?> _createAccount() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _registerEmail, password: _registerPassword)
          .then((value) {
        _addUserDetailToDatabase(value.user!.uid);
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      }
      return e.message;
    } catch (e) {
      return (e.toString());
    }
  }

  //DEFAULT LOADING STATE
  bool _registerFromLoading = false;

  void _submitForm() async {
    //SET THE FORM TO LOADING STATE
    setState(() {
      _registerFromLoading = true;
    });

    //RUN THE CREATE ACCOUNT METHOD
    String? _createAccountFeedback = await _createAccount();
    if (_createAccountFeedback != null) {
      _alertDialogBuilder(_createAccountFeedback);

      //SET THE FORM TO REGULAR STATE
      setState(() {
        _registerFromLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully.")));
      //STRING WAS NULL -> HOME PAGE
      // await _addUserDetailToDatabase().then((value) {
      Navigator.pop(context);
      // });
    }
  }

  //FOCUS NODE FOR INPUT FIELDS
  FocusNode? _inputFocusNodePassword;

  //FOCUS ON TO THE TEXT FIELD
  @override
  void initState() {
    _inputFocusNodePassword = FocusNode();
    super.initState();
  }

  //Add suer detail to firebase
  FirebaseServices? services;
  Future<void> _addUserDetailToDatabase(String userUID) async {
    debugPrint("User Uid" + userUID);

    Map<String, dynamic> data = {
      "firstName": _firstName,
      "LastName": _lastName,
      "Email": _registerEmail,
      "Address": _address,
      "PhoneNumber": _phoneNumber,
      "profileImage": ""
    };

    await FirebaseFirestore.instance
        .collection("UserDetails")
        .doc(userUID)
        .set(data);

    await SharedPref.sharePref.setUserDetailUid(userUID);
  }

  //FOCUS OFF FROM THE TEXT FIELD
  @override
  void dispose() {
    _inputFocusNodePassword!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var setUserDocId = Provider.of<UserDetailProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 24.0,
                  ),
                  child: Text(
                    "Create A New Account",
                    textAlign: TextAlign.center,
                    style: Constants.boldHeading,
                  ),
                ),
                Column(
                  children: [
                    CustomInput(
                      hintText: "First Name",
                      textCapitalization: TextCapitalization.none,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _firstName = value;
                      },
                      onSubmitted: (value) {
                        _inputFocusNodePassword!.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    CustomInput(
                      hintText: "LastName",
                      textCapitalization: TextCapitalization.none,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _lastName = value;
                      },
                      onSubmitted: (value) {
                        _inputFocusNodePassword!.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    CustomInput(
                      hintText: "Email...",
                      textCapitalization: TextCapitalization.none,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _registerEmail = value;
                      },
                      onSubmitted: (value) {
                        _inputFocusNodePassword!.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    CustomInput(
                      hintText: "Password...",
                      textCapitalization: TextCapitalization.none,
                      isPasswordField: true,
                      onChanged: (value) {
                        _registerPassword = value;
                      },
                      onSubmitted: (value) {
                        _submitForm();
                      },
                      focusNode: _inputFocusNodePassword!,
                    ),
                    CustomInput(
                      hintText: "Confirm Password",
                      textCapitalization: TextCapitalization.none,
                      textInputType: TextInputType.text,
                      isPasswordField: true,
                      onChanged: (value) {
                        _confirmPassword = value;
                      },
                      onSubmitted: (value) {
                        _inputFocusNodePassword!.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    CustomInput(
                      hintText: "Address",
                      textCapitalization: TextCapitalization.none,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _address = value;
                      },
                      onSubmitted: (value) {
                        _inputFocusNodePassword!.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    CustomInput(
                      hintText: "Phone Number",
                      textCapitalization: TextCapitalization.none,
                      textInputType: TextInputType.number,
                      onChanged: (value) {
                        _phoneNumber = value;
                      },
                      onSubmitted: (value) {
                        _inputFocusNodePassword!.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    CustomBtn(
                      text: "Create New Account",
                      onPressed: () {
                        _submitForm();
                      },
                      isLoading: _registerFromLoading,
                      outlineBtn: true,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 30.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Already have an account? ',
                          style: TextStyle(color: Colors.black)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage())),
                        child: Text("Sign In",
                            style: TextStyle(color: Colors.red[400])),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
