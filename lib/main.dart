// ignore_for_file: prefer_const_constructors
import 'package:don_ganh_app/bottomnavigation.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:don_ganh_app/screen/cart_screen.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:don_ganh_app/screen/forgot_password.dart';
import 'package:don_ganh_app/screen/gioithieu.dart';
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
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
      home: BottomnavigationMenu(),
      routes: {
        '/registerscreen': (context) => RegisterScreen(),
        '/loginscreen': (context) => LoginScreen(),
        '/gioithieu': (context) => gioithieu(),
        '/forgot_password': (context) => ForgotPassword(),
        '/new_password': (context) => NewPassword(),
        '/ban_la': (context) => BanLa(),
        '/trang_xin_chao': (context_) => TrangXinChao(),
        '/bottom': (context_) => BottomnavigationMenu(),
        '/manageraccount_screen': (context_) => ManageraccountScreen(),
        '/bottomnavigation': (context_) => BottomnavigationMenu(),
        '/cart_screen': (context_) => CartScreen(),
        // '/detail_product_screen': (context_) => DetailProductScreen(),

      },
    );
  }
}
