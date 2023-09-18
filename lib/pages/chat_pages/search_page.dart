import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/pages/chat_pages/regular_chat_pages/chat_room_page.dart';
import 'package:simple_firebase1/pages/chat_pages/group_chat_pages/group_create_or_edit_page.dart';
import 'package:simple_firebase1/services/widget_notifiers/button_selection_notifier.dart';
import 'package:simple_firebase1/services/firebase_auth_provider/user_provider.dart';

import 'regular_chat_pages/regular_chat_helper/chatroom_create_or_update.dart';
import '../../models/chatroom_model.dart';
import '../../models/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showTheUsers = false;

  final searchController = TextEditingController();

  // UserModel? get currentUser => context.read<UserProvider>().getUser;

  User? currentUser = FirebaseAuth.instance.currentUser;

  final ButtonSelectionNotifier buttonSelectionNotifier =
      ButtonSelectionNotifier();

  Stream<QuerySnapshot> get usersSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("username", isGreaterThanOrEqualTo: searchController.text)
      .snapshots();

  UserModel? get currentUserProvider => context.watch<UserProvider?>()?.getUser;

  @override
  Widget build(BuildContext context) {
    debugPrint("inside search page: ${currentUserProvider?.username}");

    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search the users',
          ),
          onFieldSubmitted: (value) {
            showTheUsers = true;
            setState(() {});
          },
        ),
      ),
      body: StreamBuilder(
        stream: usersSnapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          //
          final otherUserSnapshot = snapshot.data?.docs.where((docs) {
            return docs["uid"] != currentUser?.uid;
          }).toList();

          return Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Card(
                child: ListenableBuilder(
                  listenable: buttonSelectionNotifier,
                  builder: (context, child) {
                    if (buttonSelectionNotifier.selectedUidList.length < 2) {
                      return const ListTile(
                        title: Text("Select users to add to group"),
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                  "${(buttonSelectionNotifier.selectedUidList.length - 1).toString()} users selected"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return GroupCreatePage(
                                        // groupChatroom: groupChatroomModel,
                                        currentUser: currentUser as User,
                                        selectedUidList: buttonSelectionNotifier
                                            .selectedUidList,
                                      );
                                    },
                                  ),
                                );

                                debugPrint(
                                    "list exists: ${buttonSelectionNotifier.selectedUidList.toString()}");
                              },
                              child: const Text('Create group'),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  // itemCount: snapshot.data?.docs.length,
                  itemCount: otherUserSnapshot?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () async {
                        Map<String, dynamic> userDataFromFirebase =
                            otherUserSnapshot?[index].data()
                                as Map<String, dynamic>;

                        // After above function seperates each user with index the data is set to UserModel
                        UserModel targetUser =
                            UserModel.fromMap(userDataFromFirebase);

                        // This sends the data to CreateOrUpdateChatRoom to create/modify a chatroom between two users. If we do it outside onTap, the chatroom of all visible users will be created
                        CreateOrUpdateChatRoom createOrUpdateChatRoom =
                            CreateOrUpdateChatRoom();
                        Future<ChatRoomModel?> getChatRoomModel =
                            createOrUpdateChatRoom.getChatRoomModel(targetUser);
                        ChatRoomModel? chatRoomModel = await getChatRoomModel;
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatRoomPage(
                                chatroom: chatRoomModel as ChatRoomModel,
                                currentUser: currentUser as User,
                                targetUser: targetUser,
                              );
                            },
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: (otherUserSnapshot?[index]
                                    ["profilePicture"] !=
                                null)
                            ? CachedNetworkImageProvider(
                                otherUserSnapshot?[index]["profilePicture"] ??
                                    "",
                              )
                            : null,
                        child:
                            otherUserSnapshot?[index]["profilePicture"] == null
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(otherUserSnapshot?[index]["username"] ?? ""),
                      trailing: ListenableBuilder(
                        listenable: buttonSelectionNotifier,
                        builder: (context, child) {
                          if (buttonSelectionNotifier.buttonsClicked.isEmpty &&
                              otherUserSnapshot != null) {
                            buttonSelectionNotifier.buttonsClicked =
                                List.filled(otherUserSnapshot.length, false);
                          }
                          return IconButton(
                            onPressed: () {
                              // buttonsClicked.value[index] = !buttonsClicked.value[index];
                              // buttonsClicked.notifyListeners();
                              buttonSelectionNotifier.changeButtonState(index,
                                  otherUserSnapshot?[index]["uid"] ?? "");
                              debugPrint(buttonSelectionNotifier.buttonsClicked
                                  .toString());
                            },
                            icon:
                                buttonSelectionNotifier.buttonsClicked[index] ==
                                        false
                                    ? const Icon(Icons.check_box_outline_blank)
                                    : const Icon(Icons.check_box),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
