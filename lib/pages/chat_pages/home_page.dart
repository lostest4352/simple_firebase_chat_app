import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_firebase1/pages/auth_pages/login_page.dart';
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
  User? currentUser = FirebaseAuth.instance.currentUser;

  void signOutFromFirebase() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Didn't use provider since this is the future and stream was better for showing realtime username changes
    // UserModel? userModel = context.watch<UserProvider>().getUser;

    Stream<QuerySnapshot> chatroomSnapshot = FirebaseFirestore.instance
        .collection("chatrooms")
        // .orderBy("dateTime", descending: true)
        .snapshots();

    Stream<QuerySnapshot> allUserSnapshot = FirebaseFirestore.instance
        .collection("users")
        // .where("uid", isNotEqualTo: currentUser?.uid,)
        // .orderBy("uid")
        .orderBy("username")
        .snapshots();

    // Code when stream is used instead of provider
    Stream<QuerySnapshot> currentUserSnapshot = FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: currentUser?.uid)
        .snapshots();

    return StreamBuilder(
      stream: currentUserSnapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return const Text('Loading..');
        }
        QuerySnapshot userDataSnapshot = snapshot.data as QuerySnapshot;

        if (userDataSnapshot.docs.isEmpty) {
          return const Text('Loading..');
        }
        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage:
                    (userDataSnapshot.docs[0]["profilePicture"] == null ||
                            userDataSnapshot.docs[0]["profilePicture"] == "")
                        ? null
                        : CachedNetworkImageProvider(
                            userDataSnapshot.docs[0]["profilePicture"],
                          ),
                child: userDataSnapshot.docs[0]["profilePicture"] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            title: Text(
              userDataSnapshot.docs[0]['username'], // if streams is used
              // userModel?.username.toString() ?? "Loading...", // when provider is used
              style: const TextStyle(fontSize: 20),
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
                        return const LoginPage();
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
                    stream: allUserSnapshot,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.active) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Text('Loading..');
                      }
                      QuerySnapshot userSnapshot =
                          snapshot.data as QuerySnapshot;

                      if (userSnapshot.docs.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // This code excludes current user from the snapshot. The listview works without it and no issues outside console but we get unhandled exception in the console if we don't exclude it here
                      final otherUserSnapshot =
                          snapshot.data?.docs.where((docs) {
                        return docs["uid"] != currentUser?.uid;
                      }).toList();

                      return ListView.builder(
                        itemCount: otherUserSnapshot?.length,
                        // itemCount: thesnap.length,

                        itemBuilder: (context, index) {
                          // Get map data from snapshot as per its index and convert to format suitable for UserModel
                          Map<String, dynamic> userDataFromFirebase =
                              otherUserSnapshot?[index].data()
                                  as Map<String, dynamic>;

                          // After above function seperates each user with index the data is set to UserModel
                          UserModel targetUser =
                              UserModel.fromMap(userDataFromFirebase);

                          // This sends the data to CreateOrUpdateChatRoom to create/modify a chatroom between two users
                          CreateOrUpdateChatRoom createOrUpdateChatRoom =
                              CreateOrUpdateChatRoom();
                          Future<ChatRoomModel?> getChatRoomModel =
                              createOrUpdateChatRoom
                                  .getChatRoomModel(targetUser);

                          // Without this streambuilder, last message on homepage isnt shown instantly. It has no other function
                          return StreamBuilder(
                            stream: chatroomSnapshot,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.active) {
                                return const Center();
                              }
                              if (!snapshot.hasData) {
                                return const Text('Loading..');
                              }

                              return FutureBuilder(
                                future: getChatRoomModel,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const Text("Loading..");
                                    // return const Center();
                                  }

                                  // Old message: If used loading here, there'll be empty placeholder with loading in the listview. Since you cannot make a chatroom with yourself, no chatroom created and doesn't show in the home page listview. But there's error in console
                                  // Error now handled by excluding current user uid before listview.builder
                                  if (!snapshot.hasData) {
                                    // return const Text('Loading..');
                                    return const Center();
                                  }

                                  DateTime? date = snapshot.data?.dateTime;

                                  String? formattedDate = (date != null)
                                      ? DateFormat.jmv().format(date)
                                      : '';

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
                                              chatroom: chatRoomModel
                                                  as ChatRoomModel,
                                              currentUser: currentUser as User,
                                              targetUser: targetUser,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          // You can also just use targetUser.profilePicture here. But used the below for consistency
                                          otherUserSnapshot?[index]
                                                      ['profilePicture'] !=
                                                  null
                                              ? CachedNetworkImageProvider(
                                                  otherUserSnapshot?[index]
                                                          ['profilePicture'] ??
                                                      '')
                                              : null,
                                      child: (otherUserSnapshot?[index]
                                                  ['profilePicture'] ==
                                              null)
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(
                                      otherUserSnapshot?[index]['username'],
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
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        );
      },
    );
  }
}
