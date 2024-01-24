import 'package:flutter/cupertino.dart';

class UserDetailProvider extends ChangeNotifier {
  String? _userDetailId;
  String get getUserDetail => _userDetailId!;

  set setUserDetailsUid(String docId) {
    _userDetailId = docId;
  }
}
