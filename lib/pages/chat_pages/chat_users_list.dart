import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_page.dart';

class ChatUsersList extends StatefulWidget {
  const ChatUsersList({super.key});

  @override
  State<ChatUsersList> createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  void signOutFromFirebase() async {
    FirebaseAuth.instance.signOut();
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
              signOutFromFirebase();
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
              child: StreamBuilder(
                stream:
                    // In FutureBuilder we have get() instead of snapshots(), and ConnectionState.done instead of ConnectionState.active
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      final QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          final QueryDocumentSnapshot singleDoc =
                              dataSnapshot.docs[index];

                          return InkWell(
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
                            child: ListTile(
                              title: Text(singleDoc['username']),
                              subtitle: Text(singleDoc['age'].toString()),
                            ),
                          );
                        },
                      );
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
