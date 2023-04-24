import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final List<String> messages = [];

  insertMessage(String content) {
    messages.add(content);
    notifyListeners();
  }

  deleteMessages(int index) {
    messages.removeAt(index);
    notifyListeners();
  }

  editMessage(int index, String content) {
    messages[index] = content;
    notifyListeners();
  }
}
