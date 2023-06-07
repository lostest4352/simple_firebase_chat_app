// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? imageFile;

  TextEditingController textController = TextEditingController(text: '');

  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> get currentUserSnapshot => FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: currentUser?.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: currentUser?.email)
        .get()
        .then(
          // ignore: avoid_function_literals_in_foreach_calls
          (snapshot) => snapshot.docs.forEach(
            (element) {
              textController.text = element["username"];
            },
          ),
        );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

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
      setState(() {
        imageFile = File(croppedImage.path);
      });
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

  void uploadPhoto(String currentUserUid) async {
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
          .ref("profilePicture")
          .child(currentUser?.uid ?? '')
          .putFile(imageFile as File);

      TaskSnapshot snapshot = await uploadTask;

      String? imageURL = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserUid)
          .update({"profilePicture": imageURL}).then(
              (value) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update your information"),
        // centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
              child: CupertinoButton(
                onPressed: () {
                  showGalleryOrCameraOptions();
                },
                child: StreamBuilder<Object>(
                  stream: currentUserSnapshot,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData &&
                        snapshot.connectionState != ConnectionState.active) {
                      return const Text('Loading..');
                    }

                    QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;
                    if (userSnapshot.docs.isEmpty) {
                      return const Text('Loading..');
                    }

                    String? profilePicFromFirebase =
                        userSnapshot.docs[0]["profilePicture"];

                    return CircleAvatar(
                      radius: 60,
                      backgroundImage: (imageFile == null)
                          // ? NetworkImage(profilePicFromFirebase ?? '')
                          ? CachedNetworkImageProvider(
                              profilePicFromFirebase ?? '')
                          : FileImage(imageFile as File) as ImageProvider,
                      child:
                          (imageFile == null && profilePicFromFirebase == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                )
                              : null,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<Object>(
              stream: currentUserSnapshot,
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState != ConnectionState.active) {
                  return const Text('Loading..');
                }
                QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;
                if (userSnapshot.docs.isEmpty) {
                  return const Text('Loading..');
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      color: Colors.blue,
                      onPressed: () {
                        uploadPhoto(userSnapshot.docs[0].reference.id);
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 40,
            ),
            TextField(
              maxLines: null,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Your username',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  color: Colors.blue,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text("Updating.."),
                        );
                      },
                    );
                    FirebaseFirestore.instance
                        .collection("users")
                        // .doc(userSnapshot.docs[0].reference.id) // Use this with streambuilder if the users document uid is different from current user uid
                        .doc(currentUser?.uid)
                        .update({
                      'username': textController.text,
                    }).then((value) => Navigator.pop(context));
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
