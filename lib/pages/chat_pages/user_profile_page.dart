// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:simple_firebase1/models/user_model.dart';

import '../../models/chatroom_model.dart';
import 'chatroom_create_or_update.dart';

class UserProfilePage extends StatefulWidget {
  // final UserModel userModel;
  const UserProfilePage({
    Key? key,
    // required this.userModel,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController textController = TextEditingController(text: '');

  UserModel userModel = UserModel();

  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> get currentUserStream => FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: currentUser?.uid)
      .snapshots();

  Stream<QuerySnapshot> get otherUsersStream => FirebaseFirestore.instance
      .collection("users")
      .where("email", isNotEqualTo: currentUser?.email)
      .snapshots();

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: currentUser?.email)
        .get()
        .then(
          // ignore: avoid_function_literals_in_foreach_calls
          (snapshot) => snapshot.docs.forEach(
            (element) {
              textController.text = element['username'];
            },
          ),
        );
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
          children: [
            const SizedBox(
              height: 20,
            ),
            const Center(
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
            const SizedBox(
              height: 40,
            ),
            TextField(
              // initialValue: userSnapshot.docs[0]['username'],
              maxLines: null,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Your username',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<Object>(
                  stream: currentUserStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false &&
                        snapshot.connectionState != ConnectionState.active) {
                      return const Center();
                    }
                    QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;
                    if (userSnapshot.docs.isEmpty) {
                      return const Center();
                    }

                    return ElevatedButton(
                      onPressed: () {
                        // FirebaseFirestore.instance
                        //     .collection("users")
                        //     .doc()
                        //     .set(
                        //   {
                        //     'username': textController.text,
                        //   },
                        // );
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
