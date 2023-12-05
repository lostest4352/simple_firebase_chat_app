import 'package:flutter/material.dart';
import 'package:simple_firebase_chat_app/models/user_model.dart';

import 'auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
  final _authMethods = AuthMethods();

  UserModel? get getUser => _userModel;

  // Future<void> refreshUser() async {
  //   UserModel userModel = await _authMethods.getUserDetails();
  //   _userModel = userModel;
  //   notifyListeners();
  // }

  Stream<void> refreshUserStream() {
    return _authMethods.getUserDetailsStream().map((userModel) {
      _userModel = userModel;
      notifyListeners();
    });
  }
}
