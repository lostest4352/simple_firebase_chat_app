import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/chatroom_model.dart';
import '../models/user_model.dart';

class CreateOrUpdateChatRoom {
  final currentUser = FirebaseAuth.instance.currentUser;

  ChatRoomModel? chatRoom;

  Uuid uuid = const Uuid();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${currentUser?.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing chatroom

      final docData = snapshot.docs[0].data();

      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      // create a new chatroom
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          currentUser?.uid as String: true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;
    }
    return chatRoom;
  }
}
