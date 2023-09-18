import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/firebase_options.dart';
import 'package:simple_firebase1/pages/auth_pages/auth_page.dart';
import 'package:simple_firebase1/services/firebase_auth_provider/user_provider.dart';

void main() async {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return UserProvider();
          },
        ),
        // StreamProvider<UserModel?>.value(
        //   value: AuthMethods().getUserDetailsStream(),
        //   initialData: null,
        //   updateShouldNotify: (previous, current) => true,
        // ),
        // FutureProvider<UserModel?>(
        //   create: (_) {
        //     return AuthMethods().refreshUser();
        //   },
        //   initialData: null,
        // ),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          theme: ThemeData.dark(),
          // darkTheme: ThemeData.dark(),
          // themeMode: ThemeMode.system,
          home: const AuthPage(),
        );
      },
    );
  }
}
