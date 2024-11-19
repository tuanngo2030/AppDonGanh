import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  final String? title;
  const FollowingScreen({super.key, required this.title});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        centerTitle: true,
      ),
    );
  }
}