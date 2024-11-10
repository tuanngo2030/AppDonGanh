// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool quyenVT = false;
  bool quyenMic = false;
  bool quyenLibra = false;
  bool quyenCam = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionStates(); // Load trạng thái quyền từ SharedPreferences
  }

  Future<void> _loadPermissionStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      quyenVT = prefs.getBool('quyenVT') ?? false;
      quyenMic = prefs.getBool('quyenMic') ?? false;
      quyenLibra = prefs.getBool('quyenLibra') ?? false;
      quyenCam = prefs.getBool('quyenCam') ?? false;
    });
  }

  Future<void> _savePermissionState(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                color: Color.fromRGBO(41, 87, 35, 1),
              ),
            ),
          ),
          title: Text(
            'Cài đặt',
            style: TextStyle(
                color: Color.fromRGBO(41, 87, 35, 1),
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          child: Column(
            children: [
              Divider(thickness: 1),
              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập vị trí'),
                value: quyenVT,
                onChanged: (bool value) async {
                  setState(() {
                    quyenVT = value;
                  });
                  _savePermissionState('quyenVT', value);
                },
                activeColor: const Color.fromARGB(255, 255, 255, 255),
                inactiveThumbColor: const Color.fromARGB(255, 255, 255, 255),
                activeTrackColor: Color.fromRGBO(59, 99, 53, 1),
                inactiveTrackColor: const Color.fromARGB(66, 0, 0, 0),
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để chúng tôi có thể nhanh chóng giao hàng cho bạn',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập Micro'),
                value: quyenMic,
                onChanged: (bool value) async {
                  PermissionStatus status =
                      await Permission.microphone.request();
                  if (status == PermissionStatus.granted) {
                    setState(() {
                      quyenMic = value;
                    });
                    _savePermissionState('quyenMic', value);
                  }
                },
                activeColor: const Color.fromARGB(255, 255, 255, 255),
                inactiveThumbColor: const Color.fromARGB(255, 255, 255, 255),
                activeTrackColor: Color.fromRGBO(59, 99, 53, 1),
                inactiveTrackColor: const Color.fromARGB(66, 0, 0, 0),
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để chúng tôi có thể dễ dàng trao đổi với nhân viên của chúng tôi',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập thư viện ảnh'),
                value: quyenLibra,
                onChanged: (bool value) async {
                  PermissionStatus status = await Permission.storage.request();
                  if (status.isGranted) {
                    setState(() {
                      quyenLibra = value;
                    });
                    _savePermissionState('quyenLibra', value);
                  } else if (status.isDenied) {
                    // Hiển thị thông báo hoặc hành động khác nếu người dùng từ chối quyền
                  }
                },
                activeColor: const Color.fromARGB(255, 255, 255, 255),
                inactiveThumbColor: const Color.fromARGB(255, 255, 255, 255),
                activeTrackColor: Color.fromRGBO(59, 99, 53, 1),
                inactiveTrackColor: const Color.fromARGB(66, 0, 0, 0),
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để bạn có thể dễ dàng gửi đánh giá sản phẩm và cập nhật ảnh đai diện cho tài khoản của mình',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập máy ảnh'),
                value: quyenCam,
                onChanged: (bool value) async {
                  PermissionStatus status = await Permission.camera.request();
                  if (status == PermissionStatus.granted) {
                    setState(() {
                      quyenCam = value;
                    });
                    _savePermissionState('quyenCam', value);
                  }
                },
                activeColor: const Color.fromARGB(255, 255, 255, 255),
                inactiveThumbColor: const Color.fromARGB(255, 255, 255, 255),
                activeTrackColor: Color.fromRGBO(59, 99, 53, 1),
                inactiveTrackColor: const Color.fromARGB(66, 0, 0, 0),
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để bạn có thể dễ dàng gửi đánh giá sản phẩm và cập nhật ảnh đai diện cho tài khoản của mình',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
