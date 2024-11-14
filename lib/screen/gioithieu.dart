import 'package:flutter/material.dart';

class gioithieu extends StatefulWidget {
  const gioithieu({super.key});
  @override
  State<gioithieu> createState() => _gioithieuState();
}

class _gioithieuState extends State<gioithieu> {
  // chuyển trang sau 3 giây
    @override
  void initState() {
  
    super.initState();
    Future.delayed(Duration(seconds: 3), () {//số giây để chuyển
      Navigator.pushReplacementNamed(context, '/trang_xin_chao');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 87, 35),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              InkWell(
                child: Image.asset("lib/assets/logo.png"),
                onTap: () {
                  // Navigate to home page
                  Navigator.pushNamed(context, '/trang_xin_chao');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
