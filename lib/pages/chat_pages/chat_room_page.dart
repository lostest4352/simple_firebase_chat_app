// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_firebase1/components/chat_text_field.dart';
import 'package:simple_firebase1/models/chatroom_model.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_edit_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel userModel;
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final User firebaseUser;

  const ChatRoomPage({
    Key? key,
    required this.userModel,
    required this.targetUser,
    required this.chatroom,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> message = context.watch<ChatProvider>().messages;

    final reverseMessage = message.reversed.toList();

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
          title: const Text('Chat page'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ListView.builder(
                  reverse: true,
                  itemCount: message.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Consumer(
                        builder: (context, value, child) {
                          return Row(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: InkWell(
                                          onTap: () {
                                            showEditOrDeleteDialog(
                                              message.length - index - 1,
                                              chatController.text,
                                            );
                                          },
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
                                                color: Colors.blue[900],
                                                child: Text(
                                                  reverseMessage[index],
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                  softWrap: true,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.all(8),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 25,
                                                  fill: BorderSide
                                                      .strokeAlignCenter,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              children: const [
                Flexible(
                  child: ChatTextField(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
