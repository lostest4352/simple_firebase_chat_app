import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserMessages {
  String uid;
  String username;
  String message;
  DateTime createdAt;
  UserMessages({
    required this.uid,
    required this.username,
    required this.message,
    required this.createdAt,
  });

  UserMessages copyWith({
    String? uid,
    String? username,
    String? message,
    DateTime? createdAt,
  }) {
    return UserMessages(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'username': username,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserMessages.fromMap(Map<String, dynamic> map) {
    return UserMessages(
      uid: map['uid'] as String,
      username: map['username'] as String,
      message: map['message'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserMessages.fromJson(String source) => UserMessages.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserMessages(uid: $uid, username: $username, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant UserMessages other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.username == username &&
      other.message == message &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      username.hashCode ^
      message.hashCode ^
      createdAt.hashCode;
  }
}
