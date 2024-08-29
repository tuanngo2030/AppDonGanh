import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tenscreen extends StatefulWidget {
  const Tenscreen({super.key});

  @override
  State<Tenscreen> createState() => _Tenscreen();
}

class _Tenscreen extends State<Tenscreen> {
  final UserApiService _apiService = UserApiService();
  String _userId = '';
  String _tenNguoiDung = 'Chưa cập nhật';
  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      NguoiDung? user = await UserApiService().fetchUserDetails(storedUserId);
      if (user != null) {
        setState(() {
          _userId = storedUserId;
          _tenNguoiDung = user.tenNguoiDung ?? 'Chưa cập nhật';
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

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
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          'Hồ sơ',
          style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('Họ và tên: ${_tenNguoiDung}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
