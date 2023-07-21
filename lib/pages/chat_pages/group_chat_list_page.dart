import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_firebase1/models/group_chatroom_model.dart';
import 'package:simple_firebase1/pages/chat_pages/group_chatroom_page.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // UserModel? get currentProviderUser => context.read<UserModel?>();

  Stream<QuerySnapshot> groupChatroomSnapshot = FirebaseFirestore.instance
      .collection("groupChatrooms")
      .orderBy("dateTime", descending: true)
      .snapshots();

  Future<QuerySnapshot> allUserSnapshot =
      FirebaseFirestore.instance.collection("users").orderBy("username").get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of messages"),
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

                  final groupChatroomSnapshot =
                      snapshot.data?.docs.where((documents) {
                    // First store the list in a variable and filter the contents from it
                    List participants = documents["participants"];

                    return participants.contains(currentUser?.uid);
                  }).toList();

                  return ListView.builder(
                    itemCount: groupChatroomSnapshot?.length,
                    itemBuilder: (context, index) {
                      DateTime? date = DateTime.fromMillisecondsSinceEpoch(
                          groupChatroomSnapshot?[index]["dateTime"]);

                      String? formattedDate =
                          // " ${DateFormat.yMMMMd().format(date)} at ${DateFormat.jmv().format(date)}";
                          DateFormat.jmv().format(date);

                      Map<String, dynamic> document =
                          groupChatroomSnapshot?[index].data()
                              as Map<String, dynamic>;

                      GroupChatroomModel groupChatroom =
                          GroupChatroomModel.fromMap(document);

                      return FutureBuilder(
                          future: allUserSnapshot,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Text('Loading..');
                            }

                            //
                            final otherUserSnapshot =
                                snapshot.data?.docs.toList();

                            // codes that gets the uids from both snapshot and shows the username according to their uids present in the groupchatroom snapshot
                            List<String> allowedUsernames = [];

                            if (document.containsKey("participants")) {
                              // List<String> participants =
                              //     List<String>.from(document["participants"]);

                              List<String> participants = [];
                              // reminder: document is from group chatroom
                              List<dynamic> documentParticipants =
                                  document["participants"];
                              // first take the participants(uid) and convert them to proper List<String>
                              for (final documentParticipant in documentParticipants) {
                                participants.add(documentParticipant.toString());
                              }
                              // 
                              if (otherUserSnapshot != null) {
                                for (final doc in otherUserSnapshot) {
                                  String username = doc.get("username");
                                  if (participants.contains(doc.id)) {
                                    allowedUsernames.add(username);
                                  }
                                }
                              }
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(groupChatroomSnapshot?[index]
                                            ["participants"]
                                        .length
                                        .toString() ??
                                    "0"),
                              ),
                              title: Text(
                                "${groupChatroomSnapshot?[index]["lastMessageSender"]}: ${groupChatroomSnapshot?[index]["lastMessage"]}",
                                overflow: TextOverflow.ellipsis,
                              ),
                              // subtitle: Text(formattedDate),
                              // The join method removes bracket
                              // subtitle: Text(groupChatroomSnapshot?[index]
                              //             ["participants"]
                              //         .join(", ")
                              //         .toString() ??
                              //     "users"),

                              subtitle:
                                  Text(allowedUsernames.join(", ").toString()),

                              trailing: Text(formattedDate),
                              onTap: () {
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
                          });
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
