import 'package:don_ganh_app/Profile_Screen/gmailScreen.dart';
import 'package:don_ganh_app/Profile_Screen/profile_screen.dart';
import 'package:don_ganh_app/Profile_Screen/resetpassword.dart';
import 'package:don_ganh_app/Profile_Screen/sodienthoai_Screen.dart';
import 'package:don_ganh_app/Profile_Screen/tenScreen.dart';
import 'package:flutter/material.dart';
class SecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          'Bảo mật',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          buildMenuItem(context, 'Hồ sơ của tôi', ProfileScreen()),
          buildMenuItem(context, 'Tên người dùng', Tenscreen()),
          buildMenuItem(context, 'Điện thoại', SodienthoaiScreen()),
          buildMenuItem(context, 'Email nhận thông báo', Gmailscreen()),
          buildMenuItem(context, 'Đổi mật khẩu',Resetpassword()),
        ],
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, String title, Widget screen) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Điều hướng sang màn hình tương ứng
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
        ),
        Divider(
          color: Colors.grey,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
