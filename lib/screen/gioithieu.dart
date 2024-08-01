import 'package:flutter/material.dart';

class gioithieu extends StatelessWidget {
  const gioithieu({super.key});

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
