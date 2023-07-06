import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/models/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showTheUsers = false;

  final searchController = TextEditingController();

  // UserModel? get currentUser => context.read<UserProvider>().getUser;
  UserModel? get currentUser => context.read<UserModel?>();

  ValueNotifier<List<bool>> buttonsClicked = ValueNotifier([]);

  ValueNotifier<List<String>> selectedUid = ValueNotifier([]);

  void changeButtonState(int index, String uid) {
    buttonsClicked.value[index] = !buttonsClicked.value[index];

    if (buttonsClicked.value[index]) {
      selectedUid.value.add(uid);
    } else {
      selectedUid.value.remove(uid);
    }
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    buttonsClicked.notifyListeners();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    selectedUid.notifyListeners();
  }

  @override
  void dispose() {
    buttonsClicked.dispose();
    selectedUid.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> get usersSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("username", isGreaterThanOrEqualTo: searchController.text)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    // Add your own data by default since you need to be in the chatroom yourself. Depending on the situation, add currentUser uid above, remove empty "" value above
    if (!selectedUid.value.contains(currentUser?.uid)) {
      selectedUid.value.add(currentUser?.uid ?? "");
    }

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
                child: ValueListenableBuilder(
                  valueListenable: selectedUid,
                  builder: (context, value, child) {
                    if (value.length < 2) {
                      return const ListTile(
                        title: Text("Select users to add to group"),
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                  "${(value.length - 1).toString()} users selected"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () {},
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
                          if (buttonsClicked.value.isEmpty) {
                            buttonsClicked.value = List.generate(
                              otherUserSnapshot?.length ?? 0,
                              (_) => false,
                            );
                          }
                          return IconButton(
                            onPressed: () {
                              // buttonsClicked.value[index] = !buttonsClicked.value[index];
                              // buttonsClicked.notifyListeners();
                              changeButtonState(index,
                                  otherUserSnapshot?[index]["uid"] ?? "");
                              debugPrint(selectedUid.value.toString());
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
