import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatRoomModel {
  String? chatRoomId;
  List participants = [];
  String? lastMessage;
  DateTime? dateTime;
  
  ChatRoomModel({
    this.chatRoomId,
    required this.participants,
    this.lastMessage,
    this.dateTime,
  });


  

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatRoomId: map['chatRoomId'],
      participants: List.from(map['participants']),
      lastMessage: map['lastMessage'],
      dateTime: map['dateTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateTime']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatRoomModel.fromJson(String source) => ChatRoomModel.fromMap(json.decode(source));
}
