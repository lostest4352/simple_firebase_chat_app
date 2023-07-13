import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GroupChatroomModel {
  String? groupChatRoomId;
  List participants = [];
  String? lastMessage;
  // String? lastMessageSender;
  DateTime? dateTime;

  GroupChatroomModel({
    this.groupChatRoomId,
    required this.participants,
    this.lastMessage,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupChatRoomId': groupChatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory GroupChatroomModel.fromMap(Map<String, dynamic> map) {
    return GroupChatroomModel(
        groupChatRoomId: map['groupChatRoomId'] != null
            ? map['groupChatRoomId'] as String
            : null,
        participants: List.from(
          (map['participants'] as List)),
          lastMessage:
              map['lastMessage'] != null ? map['lastMessage'] as String : null,
          dateTime: map['dateTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int)
              : null,
        );
  }

  String toJson() => json.encode(toMap());

  factory GroupChatroomModel.fromJson(String source) =>
      GroupChatroomModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
