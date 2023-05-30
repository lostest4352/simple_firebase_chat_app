import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  
  String? username;
  String? email;
  int? age;
  String? uid;
  String? profilePicture;
  
  UserModel({
    this.username,
    this.email,
    this.age,
    this.uid,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'age': age,
      'uid': uid,
      'profilePicture': profilePicture,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] != null ? map['username'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      age: map['age'] != null ? map['age'] as int : null,
      uid: map['uid'] != null ? map['uid'] as String : null,
      profilePicture: map['profilePicture'] != null ? map['profilePicture'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
