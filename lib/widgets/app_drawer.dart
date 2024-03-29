import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:selfcheckoutapp/constants.dart';
import 'package:selfcheckoutapp/screens/edit_user_profile.dart';
import 'package:selfcheckoutapp/services/firebase_services.dart';
import 'package:selfcheckoutapp/services/shared_pref_service.dart';
import 'package:selfcheckoutapp/widgets/custom_button.dart';
import 'package:selfcheckoutapp/widgets/profile_avatar.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  FirebaseServices _firebaseServices = FirebaseServices();
  var name = "";
  var profileImage = "";

  Future _fetchProfileDetail() async {
    await FirebaseFirestore.instance
        .collection("UserDetails")
        .doc(_firebaseServices.getUserId())
        .get()
        .then((value) {
      name = value["firstName"];
      profileImage = value["profileImage"];
    });
    setState(() {});
  }

  @override
  void initState() {
    _fetchProfileDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? avatarImage;
    if (profileImage.isNotEmpty) {
      // Use NetworkImage if profileImage is a non-empty string (URL).
      avatarImage = NetworkImage(profileImage);
    } else {
      // Use AssetImage as a fallback.
      avatarImage = AssetImage("assets/avatarIcon.png");
    }
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('UserDetails')
                        .doc('displayName')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: Color(0xffD50000),
                            image: DecorationImage(
                                image: AssetImage("assets/image2-dark.png"),
                                fit: BoxFit.cover),
                          ),
                          accountName: Text(
                            _firebaseServices.getCurrentUserName() ??
                                "Display Name",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          accountEmail:
                              Text('${_firebaseServices.getCurrentEmail()}'),
                          // currentAccountPicture: Avatar(imagePath: null,),
                        );
                      } else {
                        return UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: Color(0xffD50000),
                            image: DecorationImage(
                                image: AssetImage("assets/image2-dark.png"),
                                fit: BoxFit.cover),
                          ),
                          accountName: Text(name),
                          accountEmail:
                              Text('${_firebaseServices.getCurrentEmail()}'),
                          currentAccountPicture:
                              CircleAvatar(backgroundImage: avatarImage),
                        );
                      }
                    }),
                ListTile(
                  dense: true,
                  title: Text(
                    "Welcome to Online Grocery App",
                    style: TextStyle(fontSize: 20.0, color: Color(0xff062100)),
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditUserProfile()),
                    );
                  },
                  dense: true,
                  title: Text("Profile", style: Constants.regularDarkText),
                  leading: Icon(
                    Icons.account_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  onTap: () {
                    showAboutDialog(
                        context: context,
                        applicationName: 'Online Grocery App',
                        applicationLegalese:
                            'Online Grocery App is a Self-Checkout Mobile Application.\n\n'
                            'Manzil Karmacharya \n'
                            'Sunway International Business School');
                  },
                  dense: true,
                  title: Text("About App", style: Constants.regularDarkText),
                  leading: Icon(
                    Icons.info,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  dense: true,
                  title: Text("Close", style: Constants.regularDarkText),
                  leading: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: CustomBtn(
              text: "Logout",
              onPressed: () async {
                await SharedPref.sharePref
                    .clearAllUserDetails()
                    .then((value) => confirmationAlert(context));
              },
              outlineBtn: true,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}

confirmationAlert(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
            title: Text("Logout?"),
            content: Text("Do you want to Logout?"),
            actions: [
              TextButton(
                child: Text(
                  "No",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  "Yes",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ));
}
