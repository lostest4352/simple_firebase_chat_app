import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/provider_notifiers/user_provider.dart';

import '../../firebase_helpers/chatroom_create_or_update.dart';
import '../../models/chatroom_model.dart';
import 'chat_room_page.dart';
import 'group_chat_list_page.dart';

// enum ButtonItem { settings, logout }

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ButtonItem? selectedMenu;
  User? currentUser = FirebaseAuth.instance.currentUser;

  void signOutFromFirebase() async {
    await FirebaseAuth.instance.signOut();
  }

  Stream<QuerySnapshot> chatroomSnapshot = FirebaseFirestore.instance
      .collection("chatrooms")
      .orderBy("dateTime", descending: true)
      .snapshots();

  Stream<QuerySnapshot> get allUserSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("uid", isNotEqualTo: currentUser?.uid)
      .snapshots();

  UserModel? get userModel => context.watch<UserProvider?>()?.getUser;

  @override
  Widget build(BuildContext context) {
    debugPrint(userModel?.username);

    // Code when stream is used instead of provider
    // Stream<QuerySnapshot> currentUserSnapshot = FirebaseFirestore.instance
    //     .collection("users")
    //     .where("uid", isEqualTo: currentUser?.uid)
    //     .snapshots();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
              child: CircleAvatar(
                backgroundImage: (userModel?.profilePicture == null ||
                        userModel?.profilePicture == "")
                    ? null
                    : CachedNetworkImageProvider(
                        userModel?.profilePicture ?? "",
                      ),
                child: userModel?.profilePicture == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            Expanded(
              child: Text(
                "Signed in as ${userModel?.username}", // if streams is used
                // userModel?.username.toString() ?? "Loading...", // when provider is used
                style: const TextStyle(
                  fontSize: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
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
                  onTap: () {},
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
                  stream: chatroomSnapshot,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    //
                    final thisChatroomSnapshot =
                        snapshot.data?.docs.where((docs) {
                      // First store the list in a variable and filter the contents from it
                      List participants = docs["participants"];
                      return participants.contains(currentUser?.uid);
                    }).toList();

                    return StreamBuilder(
                        stream: allUserSnapshot,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            itemCount: thisChatroomSnapshot?.length,
                            itemBuilder: (context, index) {
                              // Date time code using intl
                              DateTime? date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      thisChatroomSnapshot?[index]["dateTime"]);

                              String? formattedDate =
                                  DateFormat.yMMMMd().format(date);

                              //
                              List userUidsFromChatroom =
                                  thisChatroomSnapshot?[index]["participants"];

                              final otherUserSnapshot =
                                  snapshot.data?.docs.where((docs) {
                                return userUidsFromChatroom
                                    .contains(docs["uid"]);
                              }).toList();

                              return ListTile(
                                onTap: () async {
                                  // TODO: Add circular progress until page is reached to avoid 2 pages being opened
                                  // Only one data for a listtile so its always 0
                                  Map<String, dynamic> userDataFromFirebase =
                                      otherUserSnapshot?[0].data()
                                          as Map<String, dynamic>;

                                  // After above function seperates each user with index the data is set to UserModel
                                  UserModel targetUser =
                                      UserModel.fromMap(userDataFromFirebase);

                                  // This sends the data to CreateOrUpdateChatRoom to create/modify a chatroom between two users. If we do it outside onTap, the chatroom of all visible users will be created
                                  CreateOrUpdateChatRoom
                                      createOrUpdateChatRoom =
                                      CreateOrUpdateChatRoom();
                                  Future<ChatRoomModel?> getChatRoomModel =
                                      createOrUpdateChatRoom
                                          .getChatRoomModel(targetUser);
                                  ChatRoomModel? chatRoomModel =
                                      await getChatRoomModel;
                                  //
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
                                  backgroundImage: (otherUserSnapshot?[0]
                                              ["profilePicture"] !=
                                          null)
                                      ? CachedNetworkImageProvider(
                                          otherUserSnapshot?[0]
                                                  ["profilePicture"] ??
                                              "",
                                        )
                                      : null,
                                  child: otherUserSnapshot?[0]
                                              ["profilePicture"] ==
                                          null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(otherUserSnapshot?[0]["username"]),
                                subtitle: Text(thisChatroomSnapshot?[index]
                                    ["lastMessage"]),
                                trailing: Text(formattedDate),
                              );
                            },
                          );
                        });
                  }),
            ),
          ),
          // Old code messages not deleted to not forget
          // Expanded(
          //   child: Center(
          //     child: StreamBuilder(
          //       stream: allUserSnapshot,
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState != ConnectionState.active) {
          //           return const Center(
          //             child: CircularProgressIndicator(),
          //           );
          //         }
          //         if (!snapshot.hasData) {
          //           return const Text('Loading..');
          //         }
          //         // QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;

          //         // if (userSnapshot.docs.isEmpty) {
          //         //   return const Center(
          //         //     child: CircularProgressIndicator(),
          //         //   );
          //         // }

          //         // This code excludes current user from the snapshot. The listview works without it and no issues outside console but we get unhandled exception in the console if we don't exclude it here
          //         final otherUserSnapshot = snapshot.data?.docs.where((docs) {
          //           return docs["uid"] != currentUser?.uid;
          //         }).toList();

          //         return ListView.builder(
          //           itemCount: otherUserSnapshot?.length,
          //           // itemCount: thesnap.length,

          //           itemBuilder: (context, index) {
          //             // Get map data from snapshot as per its index and convert to format suitable for UserModel
          //             Map<String, dynamic> userDataFromFirebase =
          //                 otherUserSnapshot?[index].data()
          //                     as Map<String, dynamic>;

          //             // After above function seperates each user with index the data is set to UserModel
          //             UserModel targetUser =
          //                 UserModel.fromMap(userDataFromFirebase);

          //             // This sends the data to CreateOrUpdateChatRoom to create/modify a chatroom between two users
          //             CreateOrUpdateChatRoom createOrUpdateChatRoom =
          //                 CreateOrUpdateChatRoom();
          //             Future<ChatRoomModel?> getChatRoomModel =
          //                 createOrUpdateChatRoom.getChatRoomModel(targetUser);

          //             // Without this streambuilder, last message on homepage isnt shown instantly. It has no other function
          //             return StreamBuilder(
          //               stream: chatroomSnapshot,
          //               builder: (context, snapshot) {
          //                 if (snapshot.connectionState !=
          //                     ConnectionState.active) {
          //                   return const Center();
          //                 }
          //                 if (!snapshot.hasData) {
          //                   return const Text('Loading..');
          //                 }

          //                 return FutureBuilder(
          //                   future: getChatRoomModel,
          //                   builder: (context, snapshot) {
          //                     if (snapshot.connectionState !=
          //                         ConnectionState.done) {
          //                       // return const Text("Loading..");
          //                       return const Center(
          //                         child: CircularProgressIndicator(),
          //                       );
          //                     }

          //                     // Old message: If used loading here, there'll be empty placeholder with loading in the listview. Since you cannot make a chatroom with yourself, no chatroom created and doesn't show in the home page listview. But there's error in console
          //                     // Error now handled by excluding current user uid before listview.builder
          //                     if (!snapshot.hasData) {
          //                       // return const Text('Loading..');
          //                       return const Center();
          //                     }

          //                     DateTime? date = snapshot.data?.dateTime;

          //                     String? formattedDate = (date != null)
          //                         ? DateFormat.jmv().format(date)
          //                         : '';

          //                     return ListTile(
          //                       onTap: () async {
          //                         ChatRoomModel? chatRoomModel =
          //                             await getChatRoomModel;

          //                         //  debugPrint(chatRoomModel?.lastMessage
          //                         //     .toString());

          //                         if (!mounted) return;
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return ChatRoomPage(
          //                                 chatroom:
          //                                     chatRoomModel as ChatRoomModel,
          //                                 currentUser: currentUser as User,
          //                                 targetUser: targetUser,
          //                               );
          //                             },
          //                           ),
          //                         );
          //                       },
          //                       leading: CircleAvatar(
          //                         backgroundImage:
          //                             // You can also just use targetUser.profilePicture here. But used the below for consistency
          //                             otherUserSnapshot?[index]
          //                                         ['profilePicture'] !=
          //                                     null
          //                                 ? CachedNetworkImageProvider(
          //                                     otherUserSnapshot?[index]
          //                                             ['profilePicture'] ??
          //                                         '')
          //                                 : null,
          //                         child: (otherUserSnapshot?[index]
          //                                     ['profilePicture'] ==
          //                                 null)
          //                             ? const Icon(Icons.person)
          //                             : null,
          //                       ),
          //                       title: Text(
          //                         otherUserSnapshot?[index]['username'],
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                       subtitle: Text(
          //                         snapshot.data?.lastMessage ?? "",
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                       trailing: Text(formattedDate),
          //                     );
          //                   },
          //                 );
          //               },
          //             );
          //           },
          //         );
          //       },
          //     ),
          //   ),
          // ),
          
        ],
      ),
    );
  }
}
