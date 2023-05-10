import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/provider/chat_provider.dart';

// enum ChatMode {
//   adding,
//   editing,
// }

class ChatTextField extends StatefulWidget {
  // final ChatMode chatMode;
  final String? initialValue;

  const ChatTextField({
    super.key,

    // required this.chatMode,

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
      maxLines: null,
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
