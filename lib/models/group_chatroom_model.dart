import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GroupChatroomModel {
  String? groupChatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? dateTime;
  
  GroupChatroomModel({
    this.groupChatRoomId,
    this.participants,
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
      groupChatRoomId: map['groupChatRoomId'] != null ? map['groupChatRoomId'] as String : null,
      participants: map['participants'] != null ? Map<String, dynamic>.from((map['participants'] as Map<String, dynamic>)) : null,
      lastMessage: map['lastMessage'] != null ? map['lastMessage'] as String : null,
      dateTime: map['dateTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupChatroomModel.fromJson(String source) => GroupChatroomModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
