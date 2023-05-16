import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/components/items_text_fields.dart';
import 'package:simple_firebase1/models/user_model.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onClicked;
  const RegisterPage({required this.onClicked, super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showPassword = false;
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
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
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

        if (context.mounted) {
          Navigator.pop(context);
        }
        
        await addUserDetails(user);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        return showDialogPopup(e.code);
      }
    }
  }

  Future addUserDetails(UserModel user) async {
    await FirebaseFirestore.instance.collection("users").add(user.toMap());
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
                  height: 15,
                ),
                // Login Icon
                const Icon(
                  Icons.account_box,
                  size: 50,
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

                // Confirm password textfield
                ItemsTextField(
                  obscureText: !showPassword,
                  textController: confirmPasswordController,
                  hintText: 'Confirm Your Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      togglevisibility();
                    },
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
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
                      onTap: widget.onClicked,
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
