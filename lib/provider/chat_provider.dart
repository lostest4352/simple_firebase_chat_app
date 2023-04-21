import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final List<String> message = [];

   insertMessage(String content) {
    message.add(content);
    notifyListeners();
  }

   deleteMessage(int index) {
    message.removeAt(index);
    notifyListeners();
  }
}
