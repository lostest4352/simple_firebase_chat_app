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
  // File? imageFile;
  ValueNotifier<File?> imageFileNotifier = ValueNotifier<File?>(null);

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
      (snapshot) {
        // snapshot.docs.forEach(
        //   (element) {
        //     textController.text = element["username"];
        //   },
        // );
        for (final doc in snapshot.docs) {
          textController.text = doc["username"];
        }
      },
    );
  }

  @override
  void dispose() {
    textController.dispose();
    imageFileNotifier.dispose();
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

  void uploadPhoto(String currentUserUid) async {
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
          .ref("profilePicture")
          .child(currentUser?.uid ?? '')
          .putFile(imageFile);

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
                child: StreamBuilder(
                  stream: currentUserSnapshot,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active) {
                      return const Text('Loading..');
                    }
                    if (!snapshot.hasData) {
                      return const Text('Loading..');
                    }

                    QuerySnapshot userSnapshot = snapshot.data as QuerySnapshot;
                    if (userSnapshot.docs.isEmpty) {
                      return const Text('Loading..');
                    }

                    String? profilePicFromFirebase =
                        userSnapshot.docs[0]["profilePicture"];

                    return ListenableBuilder(
                      listenable: imageFileNotifier,
                      builder: (context, snapshot) {
                        return CircleAvatar(
                          radius: 60,
                          backgroundImage: (profilePicFromFirebase == null &&
                                  imageFileNotifier.value == null)
                              ? null
                              : (imageFileNotifier.value == null)
                                  ? CachedNetworkImageProvider(
                                      profilePicFromFirebase ?? "")
                                  : FileImage(imageFileNotifier.value as File)
                                      as ImageProvider,
                          child: (imageFileNotifier.value == null &&
                                  profilePicFromFirebase == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: currentUserSnapshot,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.active) {
                  return const Text('Loading..');
                }
                if (!snapshot.hasData) {
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
                      color: const Color.fromARGB(255, 22, 176, 102),
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
              minLines: 1,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
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
                  color: const Color.fromARGB(255, 22, 176, 102),
                  onPressed: () {
                    if (textController.text.trim() == "") {
                      return;
                    }
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
                                Text("Updating"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    FirebaseFirestore.instance
                        .collection("users")
                        // .doc(userSnapshot.docs[0].reference.id) // Use this with streambuilder if the users document uid is different from current user uid
                        .doc(currentUser?.uid)
                        .update({
                      'username': textController.text,
                    }).then((value) =>
                            Navigator.of(context, rootNavigator: true).pop());
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
