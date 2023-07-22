import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/components/items_text_fields.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/pages/auth_pages/login_page.dart';
import 'package:simple_firebase1/pages/chat_pages/main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // bool showPassword = false;
  ValueNotifier<bool> showPassword = ValueNotifier<bool>(false);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    ageController.dispose();
    showPassword.dispose();
    super.dispose();
  }

  showDialogPopup(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Text(message),
        );
      },
    );
  }

  // Create account and register the user
  Future registerUser() async {
    // show loading circle
    showDialog(
      barrierDismissible: true,
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
                Text("Signing Up"),
              ],
            ),
          ),
        );
      },
    );

    // check if all fields are entered
    if (emailController.text.trim() == '' ||
        passwordController.text.trim() == '' ||
        confirmPasswordController.text.trim() == '' ||
        usernameController.text.trim() == '' ||
        ageController.text.trim() == '') {
      Navigator.pop(context);
      showDialogPopup("Please enter all fields");
      return;
    }
    // check if password is confirmed
    else if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Navigator.pop(context);
      // show error message. password don't match
      showDialogPopup("Passwords don't match!");
      return;
    } else {
      // try registering the user
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = UserModel(
          email: emailController.text.trim(),
          username: usernameController.text.trim(),
          age: int.parse(ageController.text.trim()),
          uid: credential.user?.uid,
        );

        if (!mounted) return;
        // Navigator.pop(context);
        // Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const MainPage();
            },
          ),
        );

        await addUserDetails(user, credential.user?.uid ?? '');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        return showDialogPopup(e.code);
      }
    }
  }

  Future addUserDetails(UserModel user, String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(user.toMap());
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
                  height: 30,
                ),
                // Login Icon
                const Icon(
                  Icons.account_box,
                  size: 60,
                ),
                const SizedBox(
                  height: 15,
                ),
                // Text to the user
                Text(
                  'Welcome to the App!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade100,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                // Email textfield
                ItemsTextField(
                  textController: emailController,
                  hintText: 'Email',
                ),
                const SizedBox(
                  height: 10,
                ),

                // username textfield
                ItemsTextField(
                  textController: usernameController,
                  hintText: 'Your username',
                ),

                const SizedBox(
                  height: 10,
                ),

                // Age
                ItemsTextField(
                  textController: ageController,
                  hintText: 'Your Age',
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

                // Confirm password textfield
                ListenableBuilder(
                    listenable: showPassword,
                    builder: (context, child) {
                      return ItemsTextField(
                        obscureText: !showPassword.value,
                        textController: confirmPasswordController,
                        hintText: 'Confirm Your Password',
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
                  height: 15,
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: registerUser,
                  child: const Text(
                    'Register',
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

                // Already a member? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Alreday a member?'),
                    const SizedBox(
                      width: 4,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
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
