import 'package:flutter/material.dart';

class HoTroKhachHangScreen extends StatefulWidget {
  const HoTroKhachHangScreen({super.key});

  @override
  State<HoTroKhachHangScreen> createState() => _HoTroKhachHangScreenState();
}

class _HoTroKhachHangScreenState extends State<HoTroKhachHangScreen> {
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
                color: const Color.fromRGBO(41, 87, 35, 1),
              ),
            ),
          ),
          title: const Text(
            'Tin nhắn hỗ trợ',
            style: TextStyle(
                color: Color.fromRGBO(41, 87, 35, 1),
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
    );
  }
}
