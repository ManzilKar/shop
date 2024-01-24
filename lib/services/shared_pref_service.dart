import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPref {
  static final SharedPref _singleton = SharedPref._internal();
  factory SharedPref() {
    return _singleton;
  }
  SharedPref._internal();
  static SharedPref get sharePref => _singleton;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _firstTimeRunKey = "firsTimeRunKey";
  static const String _isOnBoardingVisited = "isOnBoardingVisited";
  static const String _userIdKey = "userIdKey";
  static const String _userFullNameKey = "_userFullNameKey";
  static const String _emailKey = "_emailKey";
  static const String _accessTokenKey = "_accessTokenKey";
  static const String _refreshTokenKey = "_refreshTokenKey";
  static const String _getUserDetailUid = "userDetailUid";

  /// If run count is equals to 1, return true
  /// Otherwise false
  Future<bool> isAppFirstRun() async {
    return (await _storage.read(key: _firstTimeRunKey)).toString() == "1";
  }

  Future<bool> isOnBoardingVisited() async {
    return (await _storage.read(key: _isOnBoardingVisited)) == "true";
  }

  Future<void> setOnBoardingVisited(bool isVisited) async {
    await _storage.write(
        key: _isOnBoardingVisited, value: isVisited.toString());
  }

  Future<String> readSecureData(String key) async {
    String value = "";
    try {
      value = (await _storage.read(key: key)) ?? "";
      debugPrint("Value  " + value);
    } catch (e) {
      print(e);
    }
    return value;
  }

  Future<void> setUserDetailUid(String Uid) async {
    debugPrint("User uid" + Uid.toString());
    await _storage.write(key: _getUserDetailUid, value: Uid.toString());
  }

  Future<void> clearAllUserDetails() async {
    await _storage.delete(key: _getUserDetailUid);
  }
}
