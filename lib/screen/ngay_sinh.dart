import 'package:flutter/material.dart';

class NgaySinh extends StatefulWidget {
  const NgaySinh({super.key});

  @override
  State<NgaySinh> createState() => _NgaySinh();
}

class _NgaySinh extends State<NgaySinh> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
           child: GestureDetector(
            onTap: () {
             Navigator.pushNamed(context, '/manageraccount_screen');
            },
            child: Container(
              child: ImageIcon(
                AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
                size: 49, // Kích thước hình ảnh
              ),
            ),
          ),
        ),
      ),
    );
  }
}
