import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase_chat_app/unused/chat_provider.dart';

class EditPage extends StatefulWidget {
  final int index;
  // final List<String>? chat;
  const EditPage({
    super.key,
    required this.index,
    // this.chat,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final textController = TextEditingController();

  List<String> get messages => context.read<ChatProvider>().messages;

  @override
  void initState() {
    final message = messages[widget.index];
    textController.text = message;
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  editFunction(int index) {
    if (textController.text.trim() != "") {
      context.read<ChatProvider>().editMessage(index, textController.text);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit your message'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          const Center(
            child: Card(
              child: Text('Edit your message'),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            // initialValue: context.watch<ChatProvider>().message[widget.index],
            minLines: 1,
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            controller: textController,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  editFunction(widget.index);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send),
              ),
            ),
          )
        ],
      ),
    );
  }
}


// Old code on chat room page which may come in use later

// void showDeleteConfirmationDialog(int index) {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Are you sure you want to delete this message?'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   title: const Text('Yes'),
//                   onTap: () {
//                     context.read<ChatProvider>().deleteMessages(index);
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('No'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }

    
    // void showEditOrDeleteDialog(int index, String content) {
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: const Text('Select an option'),
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             ListTile(
    //               onTap: () {
    //                 Navigator.pop(context);
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) {
    //                       return EditPage(
    //                         index: index,
    //                       );
    //                     },
    //                   ),
    //                 );
    //               },
    //               title: const Text('Edit message'),
    //             ),
    //             ListTile(
    //               onTap: () {
    //                 Navigator.pop(context);
    //                 showDeleteConfirmationDialog(index);
    //               },
    //               title: const Text('Delete message'),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   );
    // }
