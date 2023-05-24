import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? dateTime;
  
  ChatRoomModel({
    this.chatRoomId,
    this.participants,
    this.lastMessage,
    this.dateTime,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatRoomId: map['chatRoomId'] != null ? map['chatRoomId'] as String : null,
      participants: map['participants'] != null ? Map<String, dynamic>.from((map['participants'] as Map<String, dynamic>)) : null,
      lastMessage: map['lastMessage'] != null ? map['lastMessage'] as String : null,
      dateTime: map['dateTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatRoomModel.fromJson(String source) => ChatRoomModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
