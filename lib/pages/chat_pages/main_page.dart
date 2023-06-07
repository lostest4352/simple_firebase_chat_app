import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/pages/chat_pages/group_page.dart';
import 'package:simple_firebase1/pages/chat_pages/home_page.dart';
import 'package:simple_firebase1/pages/chat_pages/user_profile_page.dart';
import 'package:simple_firebase1/provider/user_provider.dart';

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

  // This is used in order to get current logged in user's usermodel data. Need to initialize function in init state or it'll be null
  @override
  void initState() {
    super.initState();
    getCurrentUserModelData();
  }

  void getCurrentUserModelData() async {
    UserProvider userProvider = context.read<UserProvider>();
    await userProvider.refreshUser();
  }

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
