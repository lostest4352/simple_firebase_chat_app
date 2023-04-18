import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_firebase1/pages/home_page.dart';
import 'package:simple_firebase1/pages/login_page.dart';
import 'package:simple_firebase1/pages/register_page.dart';

void main() async {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.black12,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class DefaultFirebaseOptions {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple App',
      theme: ThemeData.dark(),
      home: RegisterPage(),
    );
  }
}
