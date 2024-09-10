import 'package:flutter/material.dart';

class ProfileThumua extends StatefulWidget {
  const ProfileThumua({super.key});

  @override
  State<ProfileThumua> createState() => _ProfileThumuaState();
}

class _ProfileThumuaState extends State<ProfileThumua> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              child: ImageIcon(
                AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
                size: 49, // Kích thước hình ảnh
              ),
            ),
          ),
        ),
        title: Text('Chi tiết sản phẩm'),
      ),
    );
  }
}