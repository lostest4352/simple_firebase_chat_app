import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:simple_firebase1/models/group_chatroom_model.dart';

import '../../models/user_model.dart';

class GroupCreatePage extends StatefulWidget {
  // TODO: Make these non nullable and remove this from main page
  final GroupChatroomModel groupChatroom;
  final User currentUser;
  // final List<QueryDocumentSnapshot>? otherUserSnapshot;
  const GroupCreatePage({
    Key? key,
    required this.groupChatroom,
    required this.currentUser,
    // required this.otherUserSnapshot,
  }) : super(key: key);

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  //
  Future<List<UserModel>> getAllUsersInChatroom() async {
    List<UserModel> users = [];

    final groupChatroomDocs = await FirebaseFirestore.instance
        .collection("groupChatrooms")
        .doc(widget.groupChatroom.groupChatRoomId)
        .get();

    // final List<String> participantsIds =
    //     List<String>.from(groupChatroomDocs.data()?["participants"]);

    List<String> participantsIds = [];
    List groupChatRoomParticipantsIds =
        groupChatroomDocs.data()?["participants"];
    for (final chatRoomParticipantId in groupChatRoomParticipantsIds) {
      participantsIds.add(chatRoomParticipantId);
    }

    for (final participantsId in participantsIds) {
      final userSnapshotDocs = await FirebaseFirestore.instance
          .collection("users")
          .doc(participantsId)
          .get();
      UserModel userModel =
          UserModel.fromMap(userSnapshotDocs.data() as Map<String, dynamic>);
      users.add(userModel);
    }
    return users;
  }

  Future<List<UserModel>> get getAllUsersInChatroomFuture =>
      getAllUsersInChatroom();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create or Edit group"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Spacer(),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: CupertinoButton(
                child: CircleAvatar(
                  radius: 60,
                  child: Icon(
                    Icons.person,
                    size: 60,
                  ),
                ),
                onPressed: () {},
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: textEditingController,
                  maxLines: null,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: "The group's name",
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            Center(
              child: CupertinoButton(
                padding: const EdgeInsets.only(left: 10, right: 10),
                color: Colors.blue,
                onPressed: () {},
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Card(
              child: ListTile(
                title: Text("Participants"),
              ),
            ),
            FutureBuilder(
              future: getAllUsersInChatroomFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final dataSnapshot = snapshot.data?.toList();

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dataSnapshot?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (dataSnapshot?[index].profilePicture != null)
                                ? CachedNetworkImageProvider(
                                    dataSnapshot?[index].profilePicture ?? "",
                                  )
                                : null,
                        child: dataSnapshot?[index].profilePicture == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(dataSnapshot?[index].username ?? ""),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
