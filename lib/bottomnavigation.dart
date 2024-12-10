import 'package:don_ganh_app/screen/favorite_screen.dart';
import 'package:don_ganh_app/screen/home_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:don_ganh_app/screen/notification_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/home_thumua.dart';
import 'package:flutter/material.dart';

class BottomnavigationMenu extends StatefulWidget {
  final int initialIndex;

  const BottomnavigationMenu({super.key, this.initialIndex = 0}); // Mặc định là tab đầu tiên.

  @override
  State<BottomnavigationMenu> createState() => _BottomnavigationMenuState();
}

class _BottomnavigationMenuState extends State<BottomnavigationMenu> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex; // Lấy giá trị tab từ tham số.
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> screens = [
    const HomeScreen(),
    const HomeThumua(),
    const FavoriteScreen(),
    const NotificationScreen(),
    const ManageraccountScreen(),
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
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, size: 28),
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article, size: 28),
              label: "Bài viết",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite, size: 28),
              label: "Yêu thích",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_on_outlined),
              activeIcon: Icon(Icons.notifications_on, size: 28),
              label: "Thông báo",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              activeIcon: Icon(Icons.person_2, size: 28),
              label: "Bạn",
            ),
          ],
        ),
      ),
    );
  }
}

