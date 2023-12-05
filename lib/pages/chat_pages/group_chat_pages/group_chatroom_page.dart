// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase_chat_app/pages/chat_pages/group_chat_pages/group_create_or_edit_page.dart';
import 'package:simple_firebase_chat_app/services/firebase_auth_provider/user_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:simple_firebase_chat_app/models/group_chatroom_model.dart';
import 'package:simple_firebase_chat_app/models/user_model.dart';

import '../../../models/message_model.dart';

class GroupChatroomPage extends StatefulWidget {
  final GroupChatroomModel groupChatroom;
  final User? currentUser;

  const GroupChatroomPage({
    Key? key,
    required this.groupChatroom,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<GroupChatroomPage> createState() => _GroupChatroomPageState();
}

class _GroupChatroomPageState extends State<GroupChatroomPage> {
  final messageController = TextEditingController();

  final uuid = const Uuid();

  UserModel? get currentUserProvider => context.read<UserProvider?>()?.getUser;

  Stream<QuerySnapshot> get groupChatRoomStream => FirebaseFirestore.instance
      .collection("groupChatrooms")
      .doc(widget.groupChatroom.groupChatRoomId)
      .collection("messages")
      .orderBy("createdOn", descending: true)
      .snapshots();

  // Use future here because stream keeps loading all the time and causes problems
  Future<QuerySnapshot> allUserStream =
      FirebaseFirestore.instance.collection("users").orderBy("username").get();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    String message = messageController.text.trim();
    messageController.clear();

    if (message.isNotEmpty) {
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.currentUser?.uid,
        createdOn: DateTime.now(),
        messageText: message,
        seen: false,
      );

      // Add message to collection
      FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(widget.groupChatroom.groupChatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      // set every newest message as last message
      widget.groupChatroom.lastMessage = message;
      widget.groupChatroom.dateTime = DateTime.now();
      widget.groupChatroom.lastMessageSender =
          currentUserProvider?.username ?? "";

      // update the chatroom. This is the new message so .set is used. In something not new, .set would override the collection if the particular thing already exists. In those case use .update
      FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(widget.groupChatroom.groupChatRoomId)
          .set(widget.groupChatroom.toMap());
    }
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

  // Inputing functions directly on future/stream builders causes issues. So we need to input the value we got from function instead
  Future<List<UserModel>> get getAllUsersInChatroomFuture =>
      getAllUsersInChatroom();

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    debugPrint("inside group chatroom: ${currentUserProvider?.username}");

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.groupChatroom.groupName),
          actions: [
            // IconButton(
            //   onPressed: () {
            //     scaffoldKey.currentState?.openEndDrawer();
            //   },
            //   icon: const Icon(Icons.person),
            // ),
            InkWell(
              onTap: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: (widget.groupChatroom.groupPicture != null)
                      ? CachedNetworkImageProvider(
                          widget.groupChatroom.groupPicture ?? "",
                        )
                      : null,
                  child: widget.groupChatroom.groupPicture == null
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          width: 250,
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (widget.groupChatroom.groupPicture != null)
                        ? CachedNetworkImageProvider(
                            widget.groupChatroom.groupPicture ?? "",
                          )
                        : null,
                    child: widget.groupChatroom.groupPicture == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    widget.groupChatroom.groupName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Edit group info"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return GroupCreatePage(
                              currentUser: widget.currentUser as User,
                              selectedUidList:
                                  widget.groupChatroom.participants);
                        },
                      ),
                    );
                  },
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
                  return Expanded(
                    child: ListView.builder(
                      itemCount: dataSnapshot?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                (dataSnapshot?[index].profilePicture != null)
                                    ? CachedNetworkImageProvider(
                                        dataSnapshot?[index].profilePicture ??
                                            "",
                                      )
                                    : null,
                            child: dataSnapshot?[index].profilePicture == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(dataSnapshot?[index].username ?? ""),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: StreamBuilder(
                  stream: groupChatRoomStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active &&
                        !snapshot.hasData) {
                      return const Center(
                          // child: CircularProgressIndicator(),
                          );
                    }

                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(
                          decelerationRate: ScrollDecelerationRate.fast),
                      reverse: true,
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel chatMessage = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        // Needed package since flutter default causes problems
                        DateTime? date = chatMessage.createdOn;
                        String formattedDate = (date != null)
                            ? "${DateFormat.yMMMMd().format(date)} at ${DateFormat.jmv().format(date)}"
                            : '';

                        return Wrap(
                          alignment:
                              (chatMessage.sender == widget.currentUser?.uid)
                                  ? WrapAlignment.end
                                  : WrapAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: (chatMessage.sender ==
                                          widget.currentUser?.uid)
                                      ? 60
                                      : 15,
                                  right: (chatMessage.sender ==
                                          widget.currentUser?.uid)
                                      ? 15
                                      : 60),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (chatMessage.sender ==
                                              widget.currentUser?.uid)
                                          ? const Color.fromARGB(
                                              255, 0, 113, 85)
                                          : Colors.black38,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    // child: Text(
                                    //   chatMessage.messageText.toString(),
                                    //   style: const TextStyle(
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    child: FutureBuilder(
                                      future: allUserStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        // if (!snapshot.hasData) {
                                        //   return const Center(
                                        //     child: CircularProgressIndicator(),
                                        //   );
                                        // }

                                        // This gets the user info of only the sender. Since one listtile has only one user so the 0th position will give the correct profile pic and username data
                                        final selectedUserSnapshot =
                                            snapshot.data?.docs.where((docs) {
                                          return docs["uid"] ==
                                              chatMessage.sender;
                                        }).toList();

                                        return ListTile(
                                          // contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                (selectedUserSnapshot?[0][
                                                            "profilePicture"] !=
                                                        null)
                                                    ? CachedNetworkImageProvider(
                                                        selectedUserSnapshot?[0]
                                                                [
                                                                "profilePicture"] ??
                                                            "",
                                                      )
                                                    : null,
                                            child: selectedUserSnapshot?[0]
                                                        ["profilePicture"] ==
                                                    null
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                          title: SelectableText(
                                            chatMessage.messageText.toString(),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              // color: Colors.white,
                                            ),
                                          ),
                                          // subtitle: Text(formattedDate),
                                          // trailing: Text(chatMessage.senderUserName ?? "none"),
                                          subtitle: Wrap(
                                            children: [
                                              Text(
                                                selectedUserSnapshot?[0]
                                                        ["username"] ??
                                                    'none',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                ": $formattedDate",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Text(formattedDate),
                                ],
                              ),
                            ),
                          ],
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
            Container(
              padding: const EdgeInsets.all(5),
              color: Colors.black26,
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      // maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      controller: messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter message",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
