import 'package:flutter/material.dart';
import 'package:simple_firebase1/pages/chat_pages/group_page.dart';
import 'package:simple_firebase1/pages/chat_pages/home_page.dart';
import 'package:simple_firebase1/pages/chat_pages/user_profile_page.dart';

// Initial page with bottom navigation bar items to switch pages
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // int indexClicked = 0;
  ValueNotifier<int> indexClicked = ValueNotifier<int>(0);

  final pages = [
    const HomePage(),
    const GroupListPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: indexClicked,
        builder: (context, child) {
          return Scaffold(
            body: pages[indexClicked.value], // pages[indexClicked],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: indexClicked.value, // indexCllicked,
              onTap: (value) {
                // setState(() {
                //   indexClicked = value;
                // });
                indexClicked.value = value;
              },
              items: const [
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.group),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.person),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
