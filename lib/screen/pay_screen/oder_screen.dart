import 'package:flutter/material.dart';

class OderScreen extends StatefulWidget {
  const OderScreen({super.key});

  @override
  State<OderScreen> createState() => _OderScreenState();
}

class _OderScreenState extends State<OderScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Đơn hàng'),
          centerTitle: true,
        ),

        body: Container(
          child: ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/oder_status_screen');
            }, 
            child: Text('Click me')
          ),
        ),
      ),
    );
  }
}