// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_firebase1/pages/chat_pages/group_page.dart';
import 'package:simple_firebase1/pages/chat_pages/home_page.dart';
import 'package:simple_firebase1/pages/chat_pages/search_page.dart';
import 'package:simple_firebase1/pages/chat_pages/user_profile_page.dart';
import 'package:simple_firebase1/provider/user_provider.dart';
import 'package:simple_firebase1/widgets/keep_pages_alive.dart';

// Initial page with bottom navigation bar items to switch pages
class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // int page = 0;
  // Used valueNotifier for practice
  ValueNotifier<int> page = ValueNotifier<int>(0);

  late PageController pageController;

  List<Widget> pagesClicked = [
    const KeepPageAlive(
      child: HomePage(),
    ),
    const KeepPageAlive(
      child: SearchPage(),
    ),
    const KeepPageAlive(
      child: GroupListPage(),
    ),
    const KeepPageAlive(
      child: UserProfilePage(),
    ),
  ];

  // async cant be used in initstate so need to make a seperate function
  void getCurrentUserModelData() async {
    UserProvider userProvider = context.read<UserProvider>();
    await userProvider.refreshUser();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // This is used in order to get current logged in user's usermodel data. Need to initialize function in init state or it'll be null
    getCurrentUserModelData();
  }

  @override
  void dispose() {
    pageController.dispose();
    page.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int clickedPage) {
    page.value = clickedPage;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // body: pages[indexClicked.value], // pages[indexClicked],
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: pagesClicked,
        ),

        bottomNavigationBar: BottomNavigationBar(
          onTap: navigationTapped,
          items: const [
            BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.groups,
                color: Colors.white,
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
