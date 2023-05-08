import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_firebase1/models/chat_text_field.dart';
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

  List<String> documentIDs = [];

  final firebaseUsers = FirebaseFirestore.instance.collection('users').get();

  @override
  Widget build(BuildContext context) {
    List<String> message = context.watch<ChatProvider>().messages;

    final reverseMessage = message.reversed.toList();

    void deleteOrEditMessage(int index, String content) {
      showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(
                    width: 35,
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      context.read<ChatProvider>().deleteMessages(index);
                      Navigator.pop(context);
                    },
                    child: const Text('Delete message'),
                  ),
                ],
              ),
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
                                            deleteOrEditMessage(
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
                                              StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("users")
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    Map<String, dynamic>
                                                        userMap = snapshot.data
                                                                ?.docs[index]
                                                                .data()
                                                            as Map<String,
                                                                dynamic>;
                                                    return Text(
                                                        userMap["username"]);
                                                  } else {
                                                    return const Text(
                                                        "Data not found");
                                                  }
                                                },
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
