// ignore_for_file: prefer_const_constructors

<<<<<<< HEAD
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:don_ganh_app/screen/forgot_password.dart';
import 'package:don_ganh_app/screen/gioithieu.dart';
=======
import 'package:don_ganh_app/bottomnavigation.dart';
>>>>>>> 738e40cb68ce584ad270bee578ccb1421d0dd8e8
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:don_ganh_app/screen/new_password.dart';
import 'package:don_ganh_app/screen/register_screen.dart';
import 'package:don_ganh_app/screen/trang_xin_chao.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      home: gioithieu(),
=======
      home: BottomnavigationMenu(),
>>>>>>> 738e40cb68ce584ad270bee578ccb1421d0dd8e8
      routes: {
        '/registerscreen': (context) => RegisterScreen(),
        '/loginscreen': (context) => LoginScreen(),
        '/gioithieu': (context) => gioithieu(),
        '/forgot_password': (context) => ForgotPassword(),
        '/new_password': (context) => NewPassword(),
        '/ban_la': (context) => BanLa(),
        '/trang_xin_chao': (context_) => TrangXinChao(),
      //  '/home': (context_) => Home(),
      },
    );
  }
}
