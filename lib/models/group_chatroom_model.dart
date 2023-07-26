import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GroupChatroomModel {
  String? groupChatRoomId;
  List participants = [];
  String? lastMessage;
  String? lastMessageSender;
  String? groupPicture;
  String groupName;
  DateTime? dateTime;

  GroupChatroomModel({
    this.groupChatRoomId,
    required this.participants,
    this.lastMessage,
    this.lastMessageSender,
    this.groupPicture,
    required this.groupName,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupChatRoomId': groupChatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'groupPicture': groupPicture,
      'groupName': groupName,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory GroupChatroomModel.fromMap(Map<String, dynamic> map) {
    return GroupChatroomModel(
      groupChatRoomId: map['groupChatRoomId'],
      participants: List.from(map['participants']),
      lastMessage: map['lastMessage'],
      lastMessageSender: map['lastMessageSender'],
      groupPicture: map['groupPicture'],
      groupName: map['groupName'],
      dateTime: map['dateTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateTime']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupChatroomModel.fromJson(String source) =>
      GroupChatroomModel.fromMap(json.decode(source));
}
