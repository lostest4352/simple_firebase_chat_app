import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:simple_firebase1/models/group_chatroom_model.dart';

import '../../models/user_model.dart';

class GroupCreatePage extends StatefulWidget {
  final GroupChatroomModel groupChatroom;
  final User currentUser;

  const GroupCreatePage({
    Key? key,
    required this.groupChatroom,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final textEditingController = TextEditingController();

  ValueNotifier<File?> imageFileNotifier = ValueNotifier<File?>(null);

  TextEditingController textController = TextEditingController(text: '');

  // User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    textEditingController.text;
    //TODO Initstate here with group name later
  }

  @override
  void dispose() {
    textEditingController.dispose();
    imageFileNotifier.dispose();
    super.dispose();
  }

  //
  void selectImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? selectedImage = await imagePicker.pickImage(source: source);

    if (selectedImage != null) {
      cropImage(selectedImage);
    }
  }

  void cropImage(XFile selectedImage) async {
    final imageCropper = ImageCropper();

    CroppedFile? croppedImage = await imageCropper.cropImage(
      sourcePath: selectedImage.path,
      compressQuality: 20,
    );

    if (croppedImage != null) {
      // setState(() {
      //   imageFile = File(croppedImage.path);
      // });
      imageFileNotifier.value = File(croppedImage.path);
    }
  }

  void showGalleryOrCameraOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload profile picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo),
                title: const Text("Select from gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text("Select from camera"),
              ),
            ],
          ),
        );
      },
    );
  }

  // TODO replace all the copied code with proper group related code. may cause issues
  void uploadPhoto(String groupChatroomId) async {
    File? imageFile = imageFileNotifier.value;
    if (imageFile == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("No image selected"),
            content: Text("Please select an image"),
          );
        },
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Uploading Image"),
                ],
              ),
            ),
          );
        },
      );

      UploadTask uploadTask = FirebaseStorage.instance
          .ref("groupPicture")
          .child(groupChatroomId)
          .putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;

      String? imageURL = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(groupChatroomId)
          .update({"groupPicture": imageURL}).then(
              (value) => Navigator.pop(context));
    }
  }

  // Function to get only the users present in selectec groupChatRoom
  Future<List<UserModel>> getAllUsersInChatroom() async {
    List<UserModel> users = [];

    final groupChatroomDocs = await FirebaseFirestore.instance
        .collection("groupChatrooms")
        .doc(widget.groupChatroom.groupChatRoomId)
        .get();

    // final List<String> participantsIds =
    //     List<String>.from(groupChatroomDocs.data()?["participants"]);

    List<String> participantsIds = [];
    List groupChatRoomParticipantsIds =
        groupChatroomDocs.data()?["participants"];
    for (final chatRoomParticipantId in groupChatRoomParticipantsIds) {
      participantsIds.add(chatRoomParticipantId);
    }

    for (final participantsId in participantsIds) {
      final userSnapshotDocs = await FirebaseFirestore.instance
          .collection("users")
          .doc(participantsId)
          .get();
      UserModel userModel =
          UserModel.fromMap(userSnapshotDocs.data() as Map<String, dynamic>);
      users.add(userModel);
    }
    return users;
  }

  Future<List<UserModel>> get getAllUsersInChatroomFuture =>
      getAllUsersInChatroom();

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
                  radius: 50,
                  child: const Icon(
                    Icons.person,
                    size: 50,
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
                color: const Color.fromARGB(255, 22, 176, 102),
                onPressed: () {},
                child: const Text(
                  "Create Or Update Group",
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
            FutureBuilder(
              future: getAllUsersInChatroomFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final dataSnapshot = snapshot.data?.toList();

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dataSnapshot?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (dataSnapshot?[index].profilePicture != null)
                                ? CachedNetworkImageProvider(
                                    dataSnapshot?[index].profilePicture ?? "",
                                  )
                                : null,
                        child: dataSnapshot?[index].profilePicture == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(dataSnapshot?[index].username ?? ""),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
