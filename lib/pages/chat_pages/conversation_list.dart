import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/pages/chat_pages/chat_page.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';
import 'package:simple_firebase1/read_data/get_user_data.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  List<String> documentIDs = [];

  // get document IDs
  Future getDocumentIDs() async {
    documentIDs.clear();
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach(
            (documents) {
              documentIDs.add(documents.reference.id);
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
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
              child: FutureBuilder(
                future: getDocumentIDs(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: documentIDs.length,
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
                        // child: ListTile(
                        //   leading: const Icon(Icons.label),
                        //   title: Text(documentIDs[index]),
                        //   subtitle: Text('surname'),
                        //   trailing: const Icon(Icons.arrow_forward),
                        // ),
                        child: GetUserData(documentID: documentIDs[index]),
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
