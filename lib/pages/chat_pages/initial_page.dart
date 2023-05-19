import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/chat_pages/home_page.dart';
import 'package:simple_firebase1/pages/chat_pages/user_profile_page.dart';

// Initial page with bottom navigation bar items to switch pages
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  int indexClicked = 0;

  final pages = [
    const HomePage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[indexClicked],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexClicked,
        onTap: (value) {
          setState(() {
            indexClicked = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.person),
          ),
          // BottomNavigationBarItem(
          //   label: '',
          //   icon: Icon(Icons.search),
          // ),
        ],
      ),
    );
  }
}
