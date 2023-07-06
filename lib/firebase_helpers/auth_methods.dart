import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthMethods {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User? currentUser = _auth.currentUser;

    DocumentSnapshot snapshot =
        await _firestore.collection("users").doc(currentUser?.uid).get();
    final snapshotData = snapshot.data() as Map<String, dynamic>;

    return UserModel.fromMap(snapshotData);
  }

  Stream<UserModel> getUserDetailsStream() {
    User? currentUser = _auth.currentUser;

    return _firestore
        .collection("users")
        .doc(currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      final snapshotData = snapshot.data() as Map<String, dynamic>;
      return UserModel.fromMap(snapshotData);
    });
  }
}
