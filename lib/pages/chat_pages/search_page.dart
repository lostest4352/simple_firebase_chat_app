import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_firebase1/firebase_helpers/group_chatroom_create_or_update.dart';
import 'package:simple_firebase1/models/group_chatroom_model.dart';
import 'package:simple_firebase1/pages/chat_pages/group_chatroom_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showTheUsers = false;

  final searchController = TextEditingController();

  // UserModel? get currentUser => context.read<UserProvider>().getUser;
  // UserModel? get currentUser => context.read<UserModel?>();
  User? currentUser = FirebaseAuth.instance.currentUser;

  ValueNotifier<List<bool>> buttonsClicked = ValueNotifier([]);

  ValueNotifier<List> selectedUidList = ValueNotifier([]);

  void changeButtonState(int index, String uid) {
    // List.from needed to update the valuenotifier values when it comes to list
    buttonsClicked.value = List.from(buttonsClicked.value);
    buttonsClicked.value[index] = !buttonsClicked.value[index];

    // Add your own data by default since you need to be in the chatroom yourself. Depending on the situation, add currentUser uid above, remove empty "" value above
    if (!selectedUidList.value.contains(currentUser?.uid)) {
      // selectedUidList.value.add(currentUser?.uid ?? "");
      selectedUidList.value = List.from(selectedUidList.value)..add(currentUser?.uid ?? "");
    }

    if (buttonsClicked.value[index]) {
      // selectedUidList.value.add(uid);
      selectedUidList.value = List.from(selectedUidList.value)..add(uid);
    } else {
      // selectedUidList.value.remove(uid);
      selectedUidList.value = List.from(selectedUidList.value)..remove(uid);
    }
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    // buttonsClicked.notifyListeners();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    // selectedUidList.notifyListeners();
  }

  @override
  void dispose() {
    // When provider is used, dont use these two dispose
    buttonsClicked.dispose();
    selectedUidList.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> get usersSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("username", isGreaterThanOrEqualTo: searchController.text)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
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
                  listenable: selectedUidList,
                  builder: (context, child) {
                    if (selectedUidList.value.length < 2) {
                      return const ListTile(
                        title: Text("Select users to add to group"),
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                  "${(selectedUidList.value.length - 1).toString()} users selected"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () async {
                                CreateOrUpdateGroupChatroom
                                    createOrUpdateGroupChatroom =
                                    CreateOrUpdateGroupChatroom();

                                Future<GroupChatroomModel?>
                                    getGroupChatroomModel =
                                    createOrUpdateGroupChatroom
                                        .getGroupChatroom(
                                            selectedUidList.value);

                                GroupChatroomModel groupChatroomModel =
                                    await getGroupChatroomModel
                                        as GroupChatroomModel;

                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return GroupChatroomPage(
                                        groupChatroom: groupChatroomModel,
                                        currentUser: currentUser as User,
                                      );
                                    },
                                  ),
                                );
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
                        listenable: buttonsClicked,
                        builder: (context, child) {
                          if (buttonsClicked.value.isEmpty &&
                              otherUserSnapshot != null) {
                            buttonsClicked.value =
                                List.filled(otherUserSnapshot.length, false);
                          }
                          return IconButton(
                            onPressed: () {
                              // buttonsClicked.value[index] = !buttonsClicked.value[index];
                              // buttonsClicked.notifyListeners();
                              changeButtonState(index,
                                  otherUserSnapshot?[index]["uid"] ?? "");
                              debugPrint(selectedUidList.value.toString());
                            },
                            icon: buttonsClicked.value[index] == false
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
