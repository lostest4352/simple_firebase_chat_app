// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:simple_firebase1/models/chatroom_model.dart';
import 'package:simple_firebase1/models/message_model.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_edit_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatRoomModel chatroom;
  final User currentUser;
  final UserModel targetUser;

  const ChatRoomPage({
    Key? key,
    required this.chatroom,
    required this.currentUser,
    required this.targetUser,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
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
        sender: widget.currentUser.uid,
        createdOn: DateTime.now(),
        messageText: message,
        seen: false,
      );

      // Add message to collection
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      // set every newest message as last message
      widget.chatroom.lastMessage = message;
      widget.chatroom.dateTime = DateTime.now();

      // update the chatroom
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> chatRoomStream = FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatRoomId)
        .collection("messages")
        .orderBy("createdOn", descending: true)
        .snapshots();

    void showDeleteConfirmationDialog(int index) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure you want to delete this message?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Yes'),
                  onTap: () {
                    context.read<ChatProvider>().deleteMessages(index);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('No'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    void showEditOrDeleteDialog(int index, String content) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EditPage(
                            index: index,
                          );
                        },
                      ),
                    );
                  },
                  title: const Text('Edit message'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    showDeleteConfirmationDialog(index);
                  },
                  title: const Text('Delete message'),
                ),
              ],
            ),
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10,),
              Text("Messages with ${widget.targetUser.username ?? ''}"),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
              child: CircleAvatar(
                backgroundImage: (widget.targetUser.profilePicture == null ||
                        widget.targetUser.profilePicture == "")
                    ? null
                    : CachedNetworkImageProvider(
                        widget.targetUser.profilePicture ?? "",
                      ),
                child: widget.targetUser.profilePicture == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: StreamBuilder(
                  stream: chatRoomStream,
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
                              (currentMessage.sender == widget.currentUser.uid)
                                  ? WrapAlignment.end
                                  : WrapAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: (currentMessage.sender ==
                                          widget.currentUser.uid)
                                      ? 120
                                      : 15,
                                  right: (currentMessage.sender ==
                                          widget.currentUser.uid)
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
                                              widget.currentUser.uid)
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
