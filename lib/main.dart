import 'package:don_ganh_app/screen/ngay_sinh.dart';
import 'package:don_ganh_app/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/bottomnavigation.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:don_ganh_app/screen/gioithieu.dart';
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:don_ganh_app/screen/new_password.dart';
import 'package:don_ganh_app/screen/otp_screen.dart';
import 'package:don_ganh_app/screen/register_screen.dart';
import 'package:don_ganh_app/screen/trang_xin_chao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: gioithieu(),
      routes: {
        '/registerscreen': (context) => RegisterScreen(),
        '/loginscreen': (context) => LoginScreen(),
        '/gioithieu': (context) => gioithieu(),
        '/new_password': (context) => NewPassword(),
        '/ban_la': (context) => BanLa(),
        '/trang_xin_chao': (context_) => TrangXinChao(),
        '/bottom': (context_) => BottomnavigationMenu(),
        '/manageraccount_screen': (context_) => ManageraccountScreen(),
        '/bottomnavigation': (context_) => BottomnavigationMenu(),
        // '/detail_product_screen': (context_) => DetailProductScreen(),
        '/trang_xin_chao': (context) => TrangXinChao(),
        '/bottom': (context) => BottomnavigationMenu(),
        '/manageraccount_screen': (context) => ManageraccountScreen(),
        '/bottomnavigation': (context) => BottomnavigationMenu(),
        '/NgaySinh':(context) => NgaySinh(),
        '/ProfileScreen':(context) => ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp_screen') {
          // Kiểm tra nếu arguments không phải là String hoặc null
          final email = settings.arguments as String?;
          if (email != null) {
            return MaterialPageRoute(
              builder: (context) => OtpScreen(email: email),
            );
          }
        }
        return null; 
      },
    );
  }
}
