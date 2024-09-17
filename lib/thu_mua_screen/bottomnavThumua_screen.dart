import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/home_thumua.dart';
import 'package:don_ganh_app/thu_mua_screen/profile_thumua.dart';
import 'package:flutter/material.dart';

class BottomnavthumuaScreen extends StatefulWidget {
  const BottomnavthumuaScreen({super.key});

  @override
  State<BottomnavthumuaScreen> createState() => _BottomnavthumuaScreenState();
}

class _BottomnavthumuaScreenState extends State<BottomnavthumuaScreen> {
  int selectedIndex = 0;

  void onTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List screens = [
    ChatScreen(title: 'Chat',),
    HomeThumua(),
    ProfileThumua(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
        iconSize: 30,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Color.fromRGBO(41, 87, 35, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',  // Correct label for Home
            backgroundColor: Color.fromRGBO(41, 87, 35, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',  // Correct label for Profile
            backgroundColor: Color.fromRGBO(41, 87, 35, 1),
          ),
        ],
      ),
    );
  }
}
