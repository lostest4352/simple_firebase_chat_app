import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    final currentUser = FirebaseAuth.instance.currentUser;

    // In FutureBuilder we have get() instead of snapshots(), and ConnectionState.done instead of ConnectionState.active
    Stream<QuerySnapshot> userStream = FirebaseFirestore.instance
        .collection("users")
        .where("email", isNotEqualTo: currentUser?.email)
        .snapshots();

    Stream<QuerySnapshot> chatroomStream =
        FirebaseFirestore.instance.collection("chatrooms").snapshots();

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
                  if (snapshot.connectionState == ConnectionState.active &&
                      snapshot.hasData) {
                    QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;

                    if (userSnapshot.docs.isNotEmpty) {
                      return ListView.builder(
                        itemCount: userSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userFromFirebaseToMap =
                              userSnapshot.docs[index].data()
                                  as Map<String, dynamic>;

                          UserModel targetUser =
                              UserModel.fromMap(userFromFirebaseToMap);

                          return StreamBuilder<Object>(
                              stream: chatroomStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.active) {
                                  QuerySnapshot chatRoomSnapshot =
                                      snapshot.data as QuerySnapshot;

                                  return ListTile(
                                    onTap: () async {
                                      debugPrint(chatRoomSnapshot.docs[index]
                                              ['lastMessage']
                                          .toString());

                                      CreateOrUpdateChatRoom
                                          createOrUpdateChatRoom =
                                          CreateOrUpdateChatRoom();

                                      ChatRoomModel? chatRoomModel =
                                          await createOrUpdateChatRoom
                                              .getChatRoomModel(targetUser);

                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ChatRoomPage(
                                              targetUser: targetUser,
                                              chatroom: chatRoomModel
                                                  as ChatRoomModel,
                                              currentUser: currentUser as User,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    // onTap: () {
                                    //   debugPrint(chatRoomSnapshot.docs[index]['lastMessage'].toString());
                                    // },

                                    title: Text(
                                        userSnapshot.docs[index]['username']),
                                    subtitle: Text(chatRoomSnapshot.docs[index]
                                        ['lastMessage'] ?? 'send message'),
                                  );
                                } else {
                                  return const Center();
                                }
                              });
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
          const SizedBox(
            height: 5,
          ),
          BottomNavigationBar(
            items: const [
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
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
