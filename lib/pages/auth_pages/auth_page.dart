import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/auth_pages/login_page.dart';
import 'package:simple_firebase1/pages/chat_pages/main_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

   Stream<User?> firebaseStream =  FirebaseAuth.instance.authStateChanges();

    return Scaffold(
      body: StreamBuilder(
        stream: firebaseStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const  MainPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}