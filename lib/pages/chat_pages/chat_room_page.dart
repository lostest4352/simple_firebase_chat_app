// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          title: Text(widget.targetUser.username ?? ''),
          centerTitle: true,
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
                        child: CircularProgressIndicator(),
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
                                      ? 50
                                      : 10,
                                  right: (currentMessage.sender ==
                                          widget.currentUser.uid)
                                      ? 10
                                      : 50),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: (currentMessage.sender ==
                                          widget.currentUser.uid)
                                      ? Colors.blue[800]
                                      : Colors.black38,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  currentMessage.messageText.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
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
