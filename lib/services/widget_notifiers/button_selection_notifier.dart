import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ButtonSelectionNotifier extends ChangeNotifier {
  List<bool> buttonsClicked = [];
  List selectedUidList = [];
  List selectedUserList = [];

  User? currentUser = FirebaseAuth.instance.currentUser;

  void changeButtonState(int index, String uid) {
    buttonsClicked[index] = !buttonsClicked[index];

    if (!selectedUidList.contains(currentUser?.uid)) {
      selectedUidList.add(currentUser?.uid);
    }

    if (buttonsClicked[index]) {
      selectedUidList.add(uid);
    } else {
      selectedUidList.remove(uid);
    }

    notifyListeners();
  }
}
