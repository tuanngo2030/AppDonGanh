import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/home_thumua.dart';
import 'package:don_ganh_app/thu_mua_screen/list_conversation.dart';
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

  final List<Widget> screens = [
    const HomeThumua(),
    const ListConversation(),
    const ProfileThumua(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(41, 87, 35, 1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            currentIndex: selectedIndex,
            onTap: onTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home, size: 28),
                label: "Trang chủ",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined),
                activeIcon: Icon(Icons.chat, size: 28),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                activeIcon: Icon(Icons.person_2, size: 28),
                label: "Bạn",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
