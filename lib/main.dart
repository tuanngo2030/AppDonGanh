// ignore_for_file: prefer_const_constructors

import 'package:don_ganh_app/bottomnavigation.dart';
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:don_ganh_app/screen/register_screen.dart';
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
        '/loginscreen': (context) => LoginScreen()
      },
    );
  }
}