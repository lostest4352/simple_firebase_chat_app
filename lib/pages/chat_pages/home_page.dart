import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/auth_pages/check_if_logged_in.dart';
import 'package:simple_firebase1/pages/chat_pages/chatroom_create_or_update.dart';
import 'package:simple_firebase1/models/chatroom_model.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_room_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signOutFromFirebase() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // In FutureBuilder we have get() instead of snapshots(), and ConnectionState.done instead of ConnectionState.active
    Stream<QuerySnapshot> userStream = FirebaseFirestore.instance
        .collection("users")
        .where("email", isNotEqualTo: currentUser?.email)
        .snapshots();

    Stream<QuerySnapshot> chatroomStream =
        FirebaseFirestore.instance.collection("chatrooms").snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All users',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            enableFeedback: true,
            onPressed: () {
              signOutFromFirebase();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const CheckIfLoggedIn();
                  },
                ),
              );
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
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active &&
                        snapshot.hasData == false) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;

                    if (userSnapshot.docs.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      itemCount: userSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        // Get map data from snapshot as per its index and convert to format suitable for UserModel
                        Map<String, dynamic> userFromFirebaseToMap =
                            userSnapshot.docs[index].data()
                                as Map<String, dynamic>;

                        // After above function seperates each user with index the data is set to UserModel
                        UserModel targetUser =
                            UserModel.fromMap(userFromFirebaseToMap);

                        // This sends the data to CreateOrUpdateChatRoom to create/modify a chatroom between two users
                        CreateOrUpdateChatRoom createOrUpdateChatRoom =
                            CreateOrUpdateChatRoom();
                        Future<ChatRoomModel?> getChatRoomModel =
                            createOrUpdateChatRoom.getChatRoomModel(targetUser);

                        return StreamBuilder(
                          stream: chatroomStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData == false &&
                                snapshot.connectionState !=
                                    ConnectionState.active) {
                              return const Center();
                            }
                            return ListTile(
                              onTap: () async {
                                ChatRoomModel? chatRoomModel =
                                    await getChatRoomModel;

                                //  debugPrint(chatRoomModel?.lastMessage
                                //     .toString());

                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomPage(
                                        chatroom:
                                            chatRoomModel as ChatRoomModel,
                                        currentUser: currentUser as User,
                                        targetUser: targetUser,
                                      );
                                    },
                                  ),
                                );
                              },
                              title: Text(
                                userSnapshot.docs[index]['username'],
                              ),
                              subtitle: FutureBuilder(
                                future: getChatRoomModel,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                          ConnectionState.done &&
                                      snapshot.hasData == false) {
                                    return const Text(
                                        "Send your first message");
                                  }
                                  return Text(
                                    snapshot.data?.lastMessage as String,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
