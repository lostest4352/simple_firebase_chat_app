import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_firebase1/firebase_helpers/group_chatroom_create_or_update.dart';
import 'package:simple_firebase1/models/group_chatroom_model.dart';
import 'package:simple_firebase1/pages/chat_pages/group_chatroom_page.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> groupChatroomSnapshot = FirebaseFirestore.instance
      .collection("groupChatrooms")
      .orderBy("dateTime", descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of users"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Center(
              child: StreamBuilder(
                stream: groupChatroomSnapshot,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Text('Loading..');
                  }

                  QuerySnapshot? groupChatroomSnapshot = snapshot.data;

                  return ListView.builder(
                    itemCount: groupChatroomSnapshot?.docs.length,
                    itemBuilder: (context, index) {
                      DateTime? date = DateTime.fromMillisecondsSinceEpoch(
                          groupChatroomSnapshot?.docs[index]["dateTime"]);

                      String? formattedDate =
                          "${DateFormat.yMMMMd().format(date)} at ${DateFormat.jmv().format(date)}";

                      Map<String, dynamic> document =
                          groupChatroomSnapshot?.docs[index].data() as Map<String, dynamic>;
                      

                      GroupChatroomModel groupChatroom =
                          GroupChatroomModel.fromMap(document);

                      // No. of users on leading circular avatar
                      return ListTile(
                        title: Text(
                            groupChatroomSnapshot?.docs[index]["lastMessage"]),
                        subtitle: Text(formattedDate),
                        onTap: () async {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return GroupChatroomPage(
                                  groupChatroom: groupChatroom,
                                  currentUser: currentUser,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
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
