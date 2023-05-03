import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/firebase_options.dart';
import 'package:simple_firebase1/pages/auth_pages/auth_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';

void main() async {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.black38,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return ChatProvider();
      },
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Simple App',
          theme: ThemeData.dark(),
          home: AuthPage(),
        );
      },
    );
  }
}
