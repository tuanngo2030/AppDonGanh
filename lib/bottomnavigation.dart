// ignore_for_file: unused_import

import 'package:don_ganh_app/screen/favorite_screen.dart';
import 'package:don_ganh_app/screen/home_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:don_ganh_app/screen/notification_screen.dart';
import 'package:don_ganh_app/screen/shop_screen.dart';
import 'package:flutter/material.dart';

class BottomnavigationMenu extends StatefulWidget {
  BottomnavigationMenu({super.key});

  @override
  State<BottomnavigationMenu> createState() => _BottomnavigationMenuState();
}

class _BottomnavigationMenuState extends State<BottomnavigationMenu> {
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List screens = [
    HomeScreen(),
    ShopScreen(),
    FavoriteScreen(),
    NotificationScreen(),
    ManageraccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.green, // Màu của mục được chọn
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home", backgroundColor: Color.fromRGBO(41, 87, 35, 1)),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
        ],
      ),
    );
  }
}
