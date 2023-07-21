// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/provider/user_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:simple_firebase1/models/group_chatroom_model.dart';
import 'package:simple_firebase1/models/user_model.dart';

import '../../models/message_model.dart';

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

  // Use future here because stream keeps loading all the time and causes problems
  Future<QuerySnapshot> allUserSnapshot =
      FirebaseFirestore.instance.collection("users").get();

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

      // update the chatroom
      FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(widget.groupChatroom.groupChatRoomId)
          .set(widget.groupChatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("inside group chatroom: ${currentUserProvider?.username}");

    Stream<QuerySnapshot> groupChatRoomStream = FirebaseFirestore.instance
        .collection("groupChatrooms")
        .doc(widget.groupChatroom.groupChatRoomId)
        .collection("messages")
        .orderBy("createdOn", descending: true)
        .snapshots();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your messages"),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: StreamBuilder(
                  stream: groupChatRoomStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active &&
                        snapshot.hasData == false) {
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
                                      future: allUserSnapshot,
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

                                        // This gets the user info of only the sender. 
                                        final otherUserSnapshot =
                                            snapshot.data?.docs.where((docs) {
                                          return docs["uid"] ==
                                              chatMessage.sender;
                                        }).toList();

                                        return ListTile(
                                          // contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          leading: CircleAvatar(
                                            backgroundImage: (otherUserSnapshot?[
                                                        0]["profilePicture"] !=
                                                    null)
                                                ? CachedNetworkImageProvider(
                                                    otherUserSnapshot?[0][
                                                            "profilePicture"] ??
                                                        "",
                                                  )
                                                : null,
                                            child: otherUserSnapshot?[0]
                                                        ["profilePicture"] ==
                                                    null
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                          title: SelectableText(
                                            chatMessage.messageText
                                                .toString(),
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
                                                otherUserSnapshot?[0]
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
                      maxLines: null,
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
