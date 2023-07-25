// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_firebase1/firebase_helpers/auth_methods.dart';
import 'package:simple_firebase1/pages/chat_pages/group_chat_list_page.dart';
import 'package:simple_firebase1/pages/chat_pages/group_profile_edit_page.dart';
import 'package:simple_firebase1/pages/chat_pages/home_page.dart';
import 'package:simple_firebase1/pages/chat_pages/search_page.dart';
import 'package:simple_firebase1/pages/chat_pages/user_profile_page.dart';
import 'package:simple_firebase1/widgets/keep_pages_alive.dart';

import '../../models/user_model.dart';
import '../../provider/user_provider.dart';

// Initial page with bottom navigation bar items to switch pages
class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  late PageController pageController;

  List<Widget> allPages = [
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
    const KeepPageAlive(
      child: GroupCreateOrEditPage(),
    ),
  ];

  // async cant be used in initstate so need to make a seperate function
  // void getCurrentUserModelData() async {
  //   UserProvider userProvider = context.read<UserProvider>();
  //   await userProvider.refreshUser();
  // }

  void getCurrentUserModelDataFromStream() {
    UserProvider userProvider = context.read<UserProvider>();
    userProvider.refreshUserStream().listen((event) {});
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // This is used in order to get current logged in user's usermodel data. Need to initialize function in init state or it'll be null

    // getCurrentUserModelData();
    getCurrentUserModelDataFromStream();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int value) {
    setState(() {
      currentPageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // TODO: Remove this later. Provider not necessary for streams/futures
      child: StreamProvider<UserModel?>(
        initialData: null,
        create: (context) {
          return AuthMethods().getUserDetailsStream();
        },
        builder: (context, child) {
          return Scaffold(
            body: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: allPages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: navigationTapped,
              currentIndex: currentPageIndex,
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
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(
                    Icons.group_add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
