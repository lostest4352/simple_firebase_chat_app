import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/auth_pages/check_if_logged_in.dart';
import 'package:simple_firebase1/pages/chat_pages/initial_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

   Stream<User?> firebaseStream =  FirebaseAuth.instance.authStateChanges();

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: firebaseStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const  InitialPage();
          } else {
            return const CheckIfLoggedIn();
          }
        },
      ),
    );
  }
}