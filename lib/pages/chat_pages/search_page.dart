import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final searchController = TextEditingController();

  Future<QuerySnapshot<Map<String, dynamic>>> get usersCollection =>
      FirebaseFirestore.instance
          .collection("users")
          .where("username", isGreaterThanOrEqualTo: searchController.text)
          .get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search groups or users"),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}