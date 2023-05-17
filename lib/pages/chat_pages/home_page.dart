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

    Stream<QuerySnapshot> chatRoomStream =
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
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      if (dataSnapshot.docs.isNotEmpty) {
                        return ListView.builder(
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userFromFirebaseToMap =
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>;
                            // // We can user either UserModel or Firebase User here. But User doesnt give any option and User() gives error
                            UserModel selectedUser = UserModel.fromMap(userFromFirebaseToMap);

                            // Future<ChatRoomModel?> chatRoomId =
                            //     FirebaseChatRoomModel()
                            //         .getChatRoomModel(selectedUser);

                            // return ListTile(
                            //   onTap: () async {
                            //     ChatRoomModel? chatRoomModel =
                            //         await FirebaseChatRoomModel()
                            //             .getChatRoomModel(selectedUser);
                            //     if (chatRoomModel != null) {
                            //       if (context.mounted) {
                            //         Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //             builder: (context) {
                            //               return ChatRoomPage(
                            //                 chatroom: chatRoomModel,
                            //                 targetUser: selectedUser,
                            //                 currentUser: currentUser as User,
                            //               );
                            //             },
                            //           ),
                            //         );
                            //       }
                            //     }
                            //   },
                            //   title: Text(selectedUser.username.toString()),
                            //   subtitle: Text(chatRoomId.toString()),
                            // );
                            return StreamBuilder<Object>(
                              stream: chatRoomStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  QuerySnapshot chatRoomSnapshot =
                                      snapshot.data as QuerySnapshot;

                                  if (chatRoomSnapshot.docs.isNotEmpty) {
                                    return ListTile(
                                      onTap: () async {
                                        ChatRoomModel? chatRoomModel =
                                            await CreateOrUpdateChatRoom()
                                                .getChatRoomModel(selectedUser);

                                        if (context.mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ChatRoomPage(
                                                  chatroom: chatRoomModel
                                                      as ChatRoomModel,
                                                  targetUser: selectedUser,
                                                  currentUser:
                                                      currentUser as User,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      title: Text(
                                          selectedUser.username.toString()),
                                      subtitle: Text(
                                        chatRoomSnapshot.docs[index]
                                            ['lastMessage'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
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
