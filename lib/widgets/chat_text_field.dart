import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase_chat_app/unused/chat_provider.dart';

class ChatTextField extends StatefulWidget {
  final String? initialValue;
  const ChatTextField({
    super.key,
    this.initialValue,
  });

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: 1,
      keyboardType: TextInputType.multiline,
      maxLines: 8,
      controller: textController,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        hintText: 'Enter your message',
        suffixIcon: IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (textController.text.trim().isNotEmpty) {
              context.read<ChatProvider>().insertMessage(textController.text);
            }

            textController.clear();
          },
          icon: const Icon(Icons.send),
        ),
      ),
    );
  }
}
