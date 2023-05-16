import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    const uuid = Uuid();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${currentUser?.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing chatroom

      final docData = snapshot.docs[0].data();

      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      // create a new chatroom
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          currentUser?.uid as String: true,
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
    // In FutureBuilder we have get() instead of snapshots(), and ConnectionState.done instead of ConnectionState.active
    Stream<QuerySnapshot> userStream = FirebaseFirestore.instance
        .collection("users")
        .where("email", isNotEqualTo: currentUser?.email)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Name: ${currentUser?.email} ',
          // 'All users',
          style: const TextStyle(fontSize: 20),
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
                
                stream: userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      if (dataSnapshot.docs.isNotEmpty) {
                        return ListView.builder(
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userMap =
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>;
                            // We can user either UserModel or Firebase User here. But User doesnt give any option and User() gives error
                            UserModel selectedUser = UserModel.fromMap(userMap);
                            return ListTile(
                              onTap: () async {
                                ChatRoomModel? chatRoomModel =
                                    await getChatRoomModel(selectedUser);
                                if (chatRoomModel != null) {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChatRoomPage(
                                            chatroom: chatRoomModel,
                                            targetUser: selectedUser,
                                            currentUser: currentUser as User,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                              },
                              title: Text(selectedUser.username.toString()),
                              subtitle: Text(ChatRoomModel().lastMessage.toString()),
                            );
                          },
                        );
                      }
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                label: '',
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: Icon(Icons.search),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
