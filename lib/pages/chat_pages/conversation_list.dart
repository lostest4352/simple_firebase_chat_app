import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/models/chat_user_model.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';
import 'package:simple_firebase1/services/database.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    // final userList = FirebaseFirestore.instance.collection('chat_data').where('field');

    List<String> message = context.watch<ChatProvider>().messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // 'Email: ${user?.email.toString()}',
          'All members',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            enableFeedback: true,
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
              semanticLabel: 'Logout',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Center(
              child: Consumer<ChatProvider>(
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: message.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage();
                              },
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(Icons.label),
                          title: Text('User Name'),
                          subtitle: Text(message[index]),
                          trailing: const Icon(Icons.arrow_forward),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.abc,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.abc),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.abc),
          ),
        ],
      ),
    );
  }
}
