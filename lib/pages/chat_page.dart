import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/components/chat_text_field.dart';
import 'package:simple_firebase1/pages/chat_edit_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> message = context.watch<ChatProvider>().messages;

    final reverseMessage = message.reversed.toList();

    // int index = int.fromEnvironment(reverseMessage.toString());

    void deleteOrEditMessage(int index, String content) {
      showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatProvider>().deleteMessages(index);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                const SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  onPressed: () {
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
                    // Navigator.pop(context);
                  },
                  child: const Text('Edit message'),
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
                                        child: GestureDetector(
                                          onTap: () {
                                            deleteOrEditMessage(
                                              // reverseIndex,

                                              message.length - index - 1,
                                              chatController.text,
                                            );
                                          },
                                          child: Text(
                                            reverseMessage[index],
                                            style:
                                                const TextStyle(fontSize: 18),
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
              children: [
                Flexible(
                  child: Consumer(
                    builder: (context, value, child) {
                      return const ChatTextField();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
