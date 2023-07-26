import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_firebase1/models/group_chatroom_model.dart';
import 'package:uuid/uuid.dart';

class CreateOrUpdateGroupChatroom {
  GroupChatroomModel? groupChatroom;

  Uuid uuid = const Uuid();

  Future<GroupChatroomModel?> getGroupChatroom(List selectedUidList) async {
    // This can cause errors. Check it if issues

    // Sorted so the list will be in alphabetical order. lists wont be equal if not in order
    selectedUidList.sort();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("groupChatrooms")
        .where("participants", isEqualTo: selectedUidList)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Only one chatroom will be searched with the particular list of uids so it'll always be 0 index
      final docData = snapshot.docs[0].data();

      GroupChatroomModel existingGroupChatroom =
          GroupChatroomModel.fromMap(docData as Map<String, dynamic>);

      groupChatroom = existingGroupChatroom;
    } else {
      GroupChatroomModel newGroupChatroom = GroupChatroomModel(
        groupChatRoomId: uuid.v1(),
        participants: selectedUidList,
        lastMessage: "",
        lastMessageSender: "",
        groupName: "",
        dateTime: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection("groupChatrooms")
          .doc(newGroupChatroom.groupChatRoomId)
          .set(newGroupChatroom.toMap());
      groupChatroom = newGroupChatroom;
    }
    return groupChatroom;
  }
}
