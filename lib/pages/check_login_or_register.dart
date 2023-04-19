import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/login_page.dart';
import 'package:simple_firebase1/pages/register_page.dart';

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({super.key});

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}

class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {
  // initially show login page
  bool isLoggedIn = true;

  // toggle login and register pages
  void togglePages() {
    setState(() {
      isLoggedIn = !isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return LoginPage(
        onClicked: togglePages,
      );
    } else {
      return RegisterPage(
        onClicked: togglePages,
      );
    }
  }
}
