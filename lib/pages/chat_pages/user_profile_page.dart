// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController textController = TextEditingController(text: '');

  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> get currentUserSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: currentUser?.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: currentUser?.email)
        .get()
        .then(
          // ignore: avoid_function_literals_in_foreach_calls
          (snapshot) => snapshot.docs.forEach(
            (element) {
              textController.text = element["username"];
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
    void uploadPhoto() {}

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
                  stream: currentUserSnapshot,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false &&
                        snapshot.connectionState != ConnectionState.active) {
                      return const Text('Error Occured');
                    }
                    QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;
                    if (userSnapshot.docs.isEmpty) {
                      return const Text('Error Occured');
                    }

                    return ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              title: Text("Updating.."),
                            );
                          },
                        );
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(userSnapshot.docs[0].reference.id)
                            // .doc()
                            .update({
                          'username': textController.text,
                        }).then((value) => Navigator.pop(context));
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
