// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:simple_firebase1/models/chatroom_model.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_room_page.dart';
import 'package:uuid/uuid.dart';

class ChatUsersList extends StatefulWidget {
  // final UserModel? userModel;
  const ChatUsersList({
    Key? key,
    //  this.userModel,
  }) : super(key: key);

  @override
  State<ChatUsersList> createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  void signOutFromFirebase() async {
    FirebaseAuth.instance.signOut();
  }

  final userModel = UserModel();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    final uuid = Uuid();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing chatroom
      final docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
    } else {
      // create a new chatroom
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // 'Email: ${user?.email.toString()}',
          'All users',
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
                    FirebaseFirestore.instance
                        .collection("users")
                        .where("username", isNotEqualTo: userModel.username)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      final QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          // Not necessary to do this. Made this just to shorten code below
                          final QueryDocumentSnapshot singleDoc =
                              dataSnapshot.docs[index];
                          if (dataSnapshot.docs.isNotEmpty) {
                            Map<String, dynamic> userMap = dataSnapshot.docs[0]
                                .data() as Map<String, dynamic>;

                            // We can user either UserModel or Firebase User here
                            UserModel listedUser = UserModel.fromMap(userMap);

                            final firebaseUser = FirebaseAuth.instance.currentUser;

                            return InkWell(
                              onTap: () async {
                                ChatRoomModel? chatRoomModel =
                                    await getChatRoomModel(listedUser);

                                if (context.mounted) {}
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel as ChatRoomModel,
                                        firebaseUser: firebaseUser as User,
                                        targetUser: listedUser,
                                        userModel: userModel,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(singleDoc['username']),
                                subtitle: Text(singleDoc['age'].toString()),
                              ),
                            );
                          }
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
