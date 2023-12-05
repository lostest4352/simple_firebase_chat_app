import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_firebase_chat_app/models/group_chatroom_model.dart';
import 'package:simple_firebase_chat_app/models/user_model.dart';
import 'package:simple_firebase_chat_app/pages/chat_pages/group_chat_pages/group_chatroom_page.dart';

//
enum ButtonItem { settings, logout }

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  ButtonItem? selectedMenu;

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
        title: const Text("Group chat messages"),
        actions: [
          PopupMenuButton<ButtonItem>(
            initialValue: selectedMenu,
            onSelected: (ButtonItem item) {
              setState(() {
                selectedMenu = item;
              });
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<ButtonItem>>[
                PopupMenuItem(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                  value: ButtonItem.logout,
                  child: const Text("Logout"),
                ),
                PopupMenuItem(
                  onTap: () {
                    
                  },
                  value: ButtonItem.settings,
                  child: const Text("Settings"),
                ),
              ];
            },
          )
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
                      snapshot.data?.docs.where((docs) {
                    // First store the list in a variable and filter the contents from it
                    List participants = docs["participants"];
                    return participants.contains(currentUser?.uid);
                  }).toList();

                  return ListView.builder(
                    itemCount: groupChatroomSnapshot?.length,
                    itemBuilder: (context, index) {
                      // Date time code using intl
                      DateTime? date = DateTime.fromMillisecondsSinceEpoch(
                          groupChatroomSnapshot?[index]["dateTime"]);

                      String? formattedDate =
                          // " ${DateFormat.yMMMMd().format(date)} at ${DateFormat.jmv().format(date)}";
                          DateFormat.yMMMMd().format(date);

                      // list of all the group chatrooms the user is in will be shown and this code will send the user to the particular group chat room that was selected
                      Map<String, dynamic> firebaseGroupChatroomDocument =
                          groupChatroomSnapshot?[index].data()
                              as Map<String, dynamic>;

                      GroupChatroomModel groupChatroom =
                          GroupChatroomModel.fromMap(
                              firebaseGroupChatroomDocument);

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

                          // Getting the docs out of the database and converting it to a list in order to only include the users who are the participants of the group chatroom in the particular listtile
                          final otherUserSnapshot =
                              snapshot.data?.docs.toList();

                          // Comment 1: Here first we get the participants from the document in firebase(firebaseGroupChatroomDocument). They are in a list<String> format but firebase doesnt directly give it that way so we need to convert. We create an empty list called participants. Then we do a for loop which gets all the participants uid and add it to List<String> participants.
                          // Comment 2: Then we do a for loop for otherUserSnapshot which is QueryDocumentSnapshot. We get the docData as Map<String, dynamic> and put it in the UserModel.
                          // Comment 3: We create an empty List<UserModel> called allowedUsers. Then we check if the List<String> participants in "Comment 1" has the uid of the doc we got with for loop. If yes, then we add this UserModel to allowedUsers.

                          // List<String> allowedUsernames = []; // Use this if you only need usernames

                          List<UserModel> allowedUsers = [];

                          if (firebaseGroupChatroomDocument
                              .containsKey("participants")) {
                            // List<String> participants =
                            //     List<String>.from(document["participants"]);

                            List<String> participants = [];
                            // reminder: document is from group chatroom
                            List documentParticipants =
                                firebaseGroupChatroomDocument["participants"];
                            // first take the participants(uid) and convert them to proper List<String>
                            for (final documentParticipant
                                in documentParticipants) {
                              participants.add(documentParticipant.toString());
                            }
                            //
                            if (otherUserSnapshot != null) {
                              for (final doc in otherUserSnapshot) {
                                // String username = doc.get("username");
                                final docdata =
                                    doc.data() as Map<String, dynamic>;
                                UserModel userModel =
                                    UserModel.fromMap(docdata);
                                if (participants.contains(doc.id)) {
                                  // allowedUsernames.add(username);
                                  allowedUsers.add(userModel);
                                }
                              }
                            }
                          }

                          return ListTile(
                            // leading: CircleAvatar(
                            //   child: Text(groupChatroomSnapshot?[index]
                            //               ["participants"]
                            //           .length
                            //           .toString() ??
                            //       "0"),
                            // ),
                            leading: CircleAvatar(
                              backgroundImage: (groupChatroomSnapshot?[index]
                                          ["groupPicture"] !=
                                      null)
                                  ? CachedNetworkImageProvider(
                                      groupChatroomSnapshot?[index]
                                              ["groupPicture"] ??
                                          "",
                                    )
                                  : null,
                              child: groupChatroomSnapshot?[index]
                                          ["groupPicture"] ==
                                      null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              groupChatroomSnapshot?[index]["groupName"],
                              overflow: TextOverflow.ellipsis,
                            ),

                            // subtitle: Text(formattedDate),

                            subtitle: Text(
                              groupChatroomSnapshot?[index]["lastMessage"],
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Text(allowedUsers
                            //     .map((user) => user.username)
                            //     .join(", ")),

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
