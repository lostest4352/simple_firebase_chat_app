import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserMessages {
  String? messageId;
  String? sender;
  String? messageText;
  bool? seen;
  DateTime? createdOn;

  UserMessages({
    this.messageId,
    this.sender,
    this.messageText,
    this.seen,
    this.createdOn,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageId,
      'sender': sender,
      'messageText': messageText,
      'seen': seen,
      'createdOn': createdOn?.millisecondsSinceEpoch,
    };
  }

  factory UserMessages.fromMap(Map<String, dynamic> map) {
    return UserMessages(
      messageId: map['messageId'] != null ? map['messageId'] as String : null,
      sender: map['sender'] != null ? map['sender'] as String : null,
      messageText: map['messageText'] != null ? map['messageText'] as String : null,
      seen: map['seen'] != null ? map['seen'] as bool : null,
      createdOn: map['createdOn'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdOn'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserMessages.fromJson(String source) =>
      UserMessages.fromMap(json.decode(source) as Map<String, dynamic>);
}
