// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:simple_firebase1/models/user_model.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController textController = TextEditingController();

  UserModel userModel = UserModel();
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    textController.text;

    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void uploadData() {}

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update your information"),
        // centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const SizedBox(
                height: 20,
              ),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  child: Icon(
                    Icons.person,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // ItemsTextField(
              //   textController: textController,
              //   hintText: "Enter your bio",
              //   maxLines: null,
              // ),
              TextField(
                maxLines: null,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Enter your bio',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              // TODO Remove this later if not used
              const SizedBox(
                height: 20,
              ),
            ],
          )),
    );
  }
}
