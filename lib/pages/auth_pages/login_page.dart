import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/auth_pages/forgot_password.dart';

import '../../components/items_text_fields.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onClicked;
  const LoginPage({required this.onClicked, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // sign in user
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (context.mounted) {}
      Navigator.pop(context);
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
      setState(() {
        showPassword = !showPassword;
      });
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
                ItemsTextField(
                  obscureText: !showPassword,
                  textController: passwordController,
                  hintText: 'Enter Your Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      togglevisibility();
                    },
                  ),
                ),
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
                  child: const Text(
                    'Login',
                  ),
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
                      onTap: widget.onClicked,
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