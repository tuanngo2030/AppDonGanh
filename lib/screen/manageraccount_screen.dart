import 'package:flutter/material.dart';

class ManageraccountScreen extends StatefulWidget {
  const ManageraccountScreen({super.key});

  @override
  State<ManageraccountScreen> createState() => _ManageraccountScreenState();
}

class _ManageraccountScreenState extends State<ManageraccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Manager Account Screen"),
      ),
    );
  }
}