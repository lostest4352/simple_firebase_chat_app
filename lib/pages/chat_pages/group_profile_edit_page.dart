import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:simple_firebase1/models/group_chatroom_model.dart';

class GroupCreateOrEditPage extends StatefulWidget {
  // TODO: Make these non nullable and remove this from main page
  final GroupChatroomModel? groupChatroomModel;
  final User? user;
  const GroupCreateOrEditPage({
    Key? key,
    this.groupChatroomModel,
    this.user,
  }) : super(key: key);

  @override
  State<GroupCreateOrEditPage> createState() => _GroupCreateOrEditPageState();
}

class _GroupCreateOrEditPageState extends State<GroupCreateOrEditPage> {
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create or Edit group"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Spacer(),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: CupertinoButton(
                child: CircleAvatar(
                  radius: 60,
                  child: Icon(
                    Icons.person,
                    size: 60,
                  ),
                ),
                onPressed: () {},
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: textEditingController,
                  maxLines: null,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: "The group's name",
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            Center(
              child: CupertinoButton(
                padding: const EdgeInsets.only(left: 10, right: 10),
                color: Colors.blue,
                onPressed: () {},
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Card(
              child: ListTile(
                title: Text("Participants"),
              ),
            ),
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: 9,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text("username"),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
