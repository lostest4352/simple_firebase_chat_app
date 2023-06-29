import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/models/user_model.dart';
import 'package:simple_firebase1/provider/user_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showTheUsers = false;

  final searchController = TextEditingController();

  UserModel? get currentUser => context.read<UserProvider>().getUser;

  Stream<QuerySnapshot> get usersSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("username", isGreaterThanOrEqualTo: searchController.text)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search the users',
          ),
          onFieldSubmitted: (value) {
            showTheUsers = true;
            setState(() {});
          },
        ),
      ),
      body: StreamBuilder(
        stream: usersSnapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final otherUserSnapshot = snapshot.data?.docs.where((docs) {
            return docs["uid"] != currentUser?.uid;
          }).toList();

          return ListView.builder(
            // itemCount: snapshot.data?.docs.length,
            itemCount: otherUserSnapshot?.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      (otherUserSnapshot?[index]["profilePicture"] != null)
                          ? CachedNetworkImageProvider(
                              otherUserSnapshot?[index]["profilePicture"] ?? "",
                            )
                          : null,
                  child: otherUserSnapshot?[index]["profilePicture"] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(otherUserSnapshot?[index]["username"] ?? ""),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.check_box_outline_blank),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
