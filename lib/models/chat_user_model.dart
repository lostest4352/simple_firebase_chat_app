// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatUser {
  final String? uid;

  ChatUser({
    this.uid,
  });

}

class ChatUserList {
  final String name;
  final String message;
  final String date;

  ChatUserList({
    required this.name,
    required this.message,
    required this.date,
  });
}


class ChatData {
  final String? uid;
  final String? name;
  final String? message;
  final String? date;

  ChatData({
    this.uid,
    this.name,
    this.message,
    this.date,
  });
}
