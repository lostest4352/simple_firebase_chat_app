import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final List<String> message = [];

  insertMessage(String content) {
    message.add(content);
    notifyListeners();
  }

  deleteMessages(int index) {
    message.removeAt(index);
    notifyListeners();
  }

  editMessage(int index, String content) {
    message[index] = content;
    notifyListeners();
  }
}
