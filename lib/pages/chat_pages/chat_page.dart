import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_firebase1/components/chat_text_field.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_edit_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
                    // return Text('data');
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
                                        color: Colors.blue,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: InkWell(
                                          onTap: () {
                                            showEditOrDeleteDialog(
                                              message.length - index - 1,
                                              chatController.text,
                                            );
                                          },
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            children: [
                                              Text(
                                                reverseMessage[index],
                                                style: const TextStyle(
                                                    fontSize: 18),
                                                softWrap: true,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                                fill: BorderSide
                                                    .strokeAlignCenter,
                                              ),
                                              const SizedBox(
                                                height: 5,
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
