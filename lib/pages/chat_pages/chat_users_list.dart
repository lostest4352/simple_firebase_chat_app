import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_page.dart';
import 'package:simple_firebase1/data/get_user_data.dart';

class ChatUsersList extends StatefulWidget {
  const ChatUsersList({super.key});

  @override
  State<ChatUsersList> createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  List<String> documentIDs = [];

  // get document IDs
  Future getDocumentIDs() async {
    documentIDs.clear();
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach(
            (documents) {
              documentIDs.add(documents.reference.id);
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // 'Email: ${user?.email.toString()}',
          'All members',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            enableFeedback: true,
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
              semanticLabel: 'Logout',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Center(
              child: FutureBuilder(
                future: getDocumentIDs(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: documentIDs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ChatPage();
                              },
                            ),
                          );
                        },
                        child: GetUserData(
                          documentID: documentIDs[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       label: '',
      //       icon: Icon(
      //         Icons.abc,
      //       ),
      //     ),
      //     BottomNavigationBarItem(
      //       label: '',
      //       icon: Icon(Icons.abc),
      //     ),
      //     BottomNavigationBarItem(
      //       label: '',
      //       icon: Icon(Icons.abc),
      //     ),
      //   ],
      // ),
    );
  }
}
