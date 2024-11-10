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
    // ChatScreen(title: 'Chat',),
    const HomeThumua(),
    const ProfileThumua(),
     const ProfileThumua(),
  ];

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: ClipRRect(
         borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: BottomNavigationBar(
          
          type: BottomNavigationBarType.shifting,
          iconSize: 25,
          showSelectedLabels: false,
          unselectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
              icon: const Icon(Icons.home_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.home_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
              icon: const Icon(Icons.chat_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.chat_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
              icon: const Icon(Icons.person_pin_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.person_pin_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
          ],
        ),
      ),
    );
  }
}
