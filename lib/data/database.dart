// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/widgets.dart';

// import '../models/user_model.dart';


// class DatabaseService with ChangeNotifier {
//   final String? uid;
//   DatabaseService(this.uid);

//   // collection reference
//   final CollectionReference chatCollection =
//       FirebaseFirestore.instance.collection('chat_data');

//   Future addUserData(String email, String createdAt) async {
//     return await chatCollection.add({
//       'email' : email,
//       'created at' : createdAt,
//     });
//   }

//   Future updateUserData(String name, String message, String date) async {
//     return await chatCollection.doc(uid).set({
//       'name': name,
//       'message': message,
//       'date': date,
//     });
//   }

//   //  user list from snapshot
//   List<ChatUserList> _userListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.docs.map((document) {
//       return ChatUserList(
//         name: document.get('name'),
//         message: document.get('message'),
//         date: document.get('date'),
//       );
//     }).toList();
//   }

//   ChatData _chatDataFromSnapshot(DocumentSnapshot snapshot) {
//     return ChatData(
//       uid: uid,
//       name: snapshot.get('name'),
//       message: snapshot.get('message'),
//       date: snapshot.get('data'),
//     );
//   }

//   // get stream of list of users
//   Stream<List<ChatUserList>> get userList {
//     return chatCollection.snapshots().map((event) => _userListFromSnapshot(event));
//   }

//   // get stream of users chat/messages
//   Stream<ChatData> get chatData {
//     return chatCollection.doc(uid).snapshots().map((event) => _chatDataFromSnapshot(event));
    
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreMethods {

  final docUser = FirebaseFirestore.instance.collection('users').doc();

  Future registerUser(String ) async {}
}
