import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GroupChatroomModel {
  String? groupChatRoomId;
  List participants = [];
  String? lastMessage;
  String? lastMessageSender;
  String? lastMessageSenderProfilePic;
  DateTime? dateTime;

  GroupChatroomModel({
    this.groupChatRoomId,
    required this.participants,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageSenderProfilePic,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupChatRoomId': groupChatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageSenderProfilePic': lastMessageSenderProfilePic,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory GroupChatroomModel.fromMap(Map<String, dynamic> map) {
    return GroupChatroomModel(
      groupChatRoomId: map['groupChatRoomId'],
      participants: List.from(map['participants']),
      lastMessage: map['lastMessage'],
      lastMessageSender: map['lastMessageSender'],
      lastMessageSenderProfilePic: map['lastMessageSenderProfilePic'],
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupChatroomModel.fromJson(String source) =>
      GroupChatroomModel.fromMap(json.decode(source));
}
