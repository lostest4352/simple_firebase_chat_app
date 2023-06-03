import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    Stream<QuerySnapshot> chatroomSnapshot = FirebaseFirestore.instance
        .collection("chatrooms")
        // .orderBy("dateTime", descending: true)
        .snapshots();

    // In FutureBuilder we have get() instead of snapshots(), and ConnectionState.done instead of ConnectionState.active
    Stream<QuerySnapshot> nonCurrentUserSnapshot = FirebaseFirestore.instance
        .collection("users")
        .where("email", isNotEqualTo: currentUser?.email)
        .snapshots();

    Stream<QuerySnapshot> currentUserSnapshot = FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: currentUser?.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: currentUserSnapshot,
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState != ConnectionState.active) {
              return const Center(
                child: Text('Loading..'),
              );
            }
            QuerySnapshot userDataSnapshot = snapshot.data as QuerySnapshot;
            return Text(
              userDataSnapshot.docs[0]['username'],
              style: const TextStyle(fontSize: 20),
            );
          },
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
                  stream: nonCurrentUserSnapshot,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active &&
                        !snapshot.hasData) {
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

                        // Without this streambuilder, last message on homepage isnt shown instantly. It has no other function
                        return StreamBuilder(
                          stream: chatroomSnapshot,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData &&
                                snapshot.connectionState !=
                                    ConnectionState.active) {
                              return const Center();
                            }

                            return FutureBuilder(
                              future: getChatRoomModel,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                        ConnectionState.done &&
                                    !snapshot.hasData) {
                                  return const Text("Loading..");
                                }

                                DateTime? date = snapshot.data?.dateTime;

                                String? formattedDate =
                                    // "0${date.day}-0${date.month}-${date.year} at ${date.hour}:${date.minute}";
                                    date != null
                                        ? DateFormat.Hm().format(date)
                                        : '';

                                return ListTile(
                                  onTap: () async {
                                    debugPrint(date.toString());
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
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        // NetworkImage(targetUser.profilePicture.toString()),
                                        CachedNetworkImageProvider(targetUser
                                            .profilePicture
                                            .toString()),
                                  ),
                                  title: Text(
                                    userSnapshot.docs[index]['username'],
                                  ),
                                  subtitle: Text(
                                    snapshot.data?.lastMessage ?? "",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(formattedDate),
                                );
                              },
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
