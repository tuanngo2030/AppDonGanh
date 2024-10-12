// ignore_for_file: unused_import

import 'package:don_ganh_app/screen/favorite_screen.dart';
import 'package:don_ganh_app/screen/home_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:don_ganh_app/screen/notification_screen.dart';
import 'package:don_ganh_app/screen/notifition_screen.dart';
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
    NotifitionScreen(),
    ManageraccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: ClipRRect(
         borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          iconSize: 30,
          showSelectedLabels: false,
          unselectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          backgroundColor: Color.fromRGBO(41, 87, 35, 1),
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(41, 87, 35, 1),
              icon: Icon(Icons.home_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.home_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(41, 87, 35, 1),
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.shopping_cart_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(41, 87, 35, 1),
              icon: Icon(Icons.favorite_outline),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.favorite_outline, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(41, 87, 35, 1),
              icon: Icon(Icons.chat_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.chat_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(41, 87, 35, 1),
              icon: Icon(Icons.person_pin_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.person_pin_outlined, color: Color.fromRGBO(41, 87, 35, 1)),
              ),
              label: "Home",
            ),
          ],
        ),
      ),
    );
  }
}
