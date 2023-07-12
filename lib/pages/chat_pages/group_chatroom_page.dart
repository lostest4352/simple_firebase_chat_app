// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:simple_firebase1/models/group_chatroom_model.dart';

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

      // update the chatroom
      FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(widget.groupChatroom.groupChatRoomId)
          .set(widget.groupChatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      reverse: true,
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel currentMessage = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        // Needed package since flutter default causes problems
                        DateTime? date = currentMessage.createdOn;
                        String formattedDate = (date != null)
                            ? "${DateFormat.yMMMMd().format(date)} at ${DateFormat.jmv().format(date)}"
                            : '';

                        return Wrap(
                          alignment:
                              (currentMessage.sender == widget.currentUser?.uid)
                                  ? WrapAlignment.end
                                  : WrapAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: (currentMessage.sender ==
                                          widget.currentUser?.uid)
                                      ? 120
                                      : 15,
                                  right: (currentMessage.sender ==
                                          widget.currentUser?.uid)
                                      ? 15
                                      : 120),
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
                                      color: (currentMessage.sender ==
                                              widget.currentUser?.uid)
                                          ? const Color.fromARGB(
                                              255, 0, 113, 85)
                                          : Colors.black38,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    // child: Text(
                                    //   currentMessage.messageText.toString(),
                                    //   style: const TextStyle(
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    child: ListTile(
                                      // contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      title: Text(
                                        currentMessage.messageText.toString(),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          // color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(formattedDate),
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
