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

import '../../firebase_helpers/group_chatroom_create_or_update.dart';
import '../../models/user_model.dart';

class GroupCreatePage extends StatefulWidget {
  // final GroupChatroomModel groupChatroom;
  final User currentUser;
  final List<dynamic> selectedUidList;

  const GroupCreatePage({
    Key? key,
    // required this.groupChatroom,
    required this.currentUser,
    required this.selectedUidList,
  }) : super(key: key);

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final textEditingController = TextEditingController();

  ValueNotifier<File?> imageFileNotifier = ValueNotifier<File?>(null);

  @override
  void initState() {
    super.initState();
    textEditingController.text;
    FirebaseFirestore.instance
        .collection("groupChatrooms")
        .where("participants", isEqualTo: widget.selectedUidList)
        .get()
        .then((snapshot) {
      for (final doc in snapshot.docs) {
        textEditingController.text = doc["groupName"] ?? "";
      }
    });
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

  void uploadData() async {
    // TODO Make barrierdismissable false when everything works

    CreateOrUpdateGroupChatroom createOrUpdateGroupChatroom =
        CreateOrUpdateGroupChatroom();

    Future<GroupChatroomModel?> getGroupChatroomModel =
        createOrUpdateGroupChatroom.getGroupChatroom(widget.selectedUidList);

    GroupChatroomModel? groupChatroomModel = await getGroupChatroomModel;

    if (textEditingController.text == "") {
      return;
    } else {
      FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(groupChatroomModel?.groupChatRoomId)
          .update({
        'groupName': textEditingController.text,
      }).then((value) {
        Navigator.of(context, rootNavigator: true).pop();
      });
    }

    // Code to upload photo
    File? imageFile = imageFileNotifier.value;

    if (imageFile == null) {
      return;
    } else {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("groupPicture")
          .child(groupChatroomModel?.groupChatRoomId ?? "")
          .putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask;

      String? imageURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(groupChatroomModel?.groupChatRoomId)
          .update({"groupPicture": imageURL})
          // .then((value) {
        // Navigator.of(context, rootNavigator: true).pop();
      // })
      ;
    }
  }

  // Function to get only the users present in selectec groupChatRoom
  Future<List<UserModel>> getAllUsersInChatroom() async {
    List<UserModel> users = [];

    List<String> participantsIds = [];
    List groupChatRoomParticipantsIds = widget.selectedUidList;

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

  Future<QuerySnapshot>? get groupChatroomSnapshot => FirebaseFirestore.instance
      .collection("groupChatrooms")
      .where("participants", isEqualTo: widget.selectedUidList)
      .get();

  @override
  Widget build(BuildContext context) {
    debugPrint("list exists in group page: ${widget.selectedUidList}");

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

            FutureBuilder(
              future: groupChatroomSnapshot,
              builder: (context, snapshot) {
                // if (!snapshot.hasData) {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                QuerySnapshot? groupSnapshot = snapshot.data;
                String? profilePicFromFirebase = "";
                // groupSnapshot?.docs[0]["groupPicture"] ??
                //  "";

                if (groupSnapshot != null && groupSnapshot.docs.isNotEmpty) {
                  profilePicFromFirebase =
                      groupSnapshot.docs[0]["groupPicture"];
                }

                return Center(
                  child: ListenableBuilder(
                    listenable: imageFileNotifier,
                    builder: (context, child) {
                      return CupertinoButton(
                        onPressed: () {
                          showGalleryOrCameraOptions();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: ((profilePicFromFirebase == "" ||
                                      profilePicFromFirebase == null) &&
                                  imageFileNotifier.value == null)
                              ? null
                              : (imageFileNotifier.value == null)
                                  ? CachedNetworkImageProvider(
                                      profilePicFromFirebase ?? "")
                                  : FileImage(imageFileNotifier.value as File)
                                      as ImageProvider,
                          child: ((profilePicFromFirebase == "" ||
                                      profilePicFromFirebase == null) &&
                                  imageFileNotifier.value == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
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
                onPressed: () {
                  showDialog(
                    barrierDismissible: true,
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
                              Text("Updating"),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  uploadData();
                },
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
