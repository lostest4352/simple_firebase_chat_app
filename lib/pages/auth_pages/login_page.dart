import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/auth_pages/forgot_password.dart';
import 'package:simple_firebase1/pages/auth_pages/register_page.dart';
import 'package:simple_firebase1/pages/chat_pages/main_page.dart';

import '../../components/items_text_fields.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // bool showPassword = false;
  ValueNotifier<bool> showPassword = ValueNotifier<bool>(false);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    showPassword.dispose();
    super.dispose();
  }

  // sign in user
  void signUserIn() async {
    // show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text("Logging In"),
              ],
            ),
          ),
        );
      },
    );

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MainPage();
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue,
            title: Text(e.code),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    void togglevisibility() {
      // setState(() {
      //   showPassword = !showPassword;
      // });
      showPassword.value = !showPassword.value;
    }

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),

                // Login Icon
                const Icon(
                  Icons.account_box,
                  size: 80,
                ),
                const SizedBox(
                  height: 25,
                ),

                // Text to the user
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade100,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                // Email textfield
                ItemsTextField(
                  textController: emailController,
                  hintText: 'Email',
                ),
                const SizedBox(
                  height: 10,
                ),

                // Password textfield
                ListenableBuilder(
                    listenable: showPassword,
                    builder: (context, child) {
                      return ItemsTextField(
                        obscureText: !showPassword.value,
                        textController: passwordController,
                        hintText: 'Enter Your Password',
                        suffixIcon: IconButton(
                          icon: Icon(showPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            togglevisibility();
                          },
                        ),
                      );
                    }),
                const SizedBox(
                  height: 10,
                ),

                // Forgot password?
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const ForgotPasswordPage();
                            },
                          ));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: signUserIn,
                  child: const Text('Login'),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.white30,
                      ),
                    ),
                    Text('Or continue with'),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),

                // Google sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SizedBox(
                        height: 40,
                        child: Image.asset('assets/images/google.png'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                // Not a member? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(
                      width: 4,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RegisterPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
