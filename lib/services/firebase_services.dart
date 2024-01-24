import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String? getUserId() {
    return _firebaseAuth.currentUser!.uid;
  }

  String? getCurrentUserName() {
    return _firebaseAuth.currentUser!.displayName;
  }

  String? getCurrentEmail() {
    return _firebaseAuth.currentUser!.email;
  }

  final CollectionReference productsRef =
      FirebaseFirestore.instance.collection('Products');

  final CollectionReference usersCartRef = FirebaseFirestore.instance
      .collection(
          'Users'); // TO STORE USERS CART | User-->userId->Cart-->productId

  final CollectionReference usersCartHistoryRef =
      FirebaseFirestore.instance.collection("UsersCartHistory");

  final CollectionReference cartHistoryForAdminRef =
      FirebaseFirestore.instance.collection("CartHistoryForAdmin");

  final CollectionReference productsLocationRef =
      FirebaseFirestore.instance.collection("ProductLocation");

  final CollectionReference userDetailsRef =
      FirebaseFirestore.instance.collection("UserDetails");
  String? _userDetaiilId;
  String get getUserDetailId => _userDetaiilId!;
  set userDetailId(String docId) {
    _userDetaiilId = docId;
  }

  Future<void> userSetup(String displayName) async {
    CollectionReference users = _firebaseFirestore.collection('UserDetails');

    String uid = getCurrentEmail().toString();
    String displayName = getCurrentUserName().toString();

    users.doc(getUserId()).set({'displayName': displayName, 'uid': uid});
    return;
  }
}
