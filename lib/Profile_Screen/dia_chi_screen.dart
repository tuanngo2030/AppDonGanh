import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaChiScreen extends StatefulWidget {
  const DiaChiScreen({super.key});

  @override
  State<DiaChiScreen> createState() => _DiaChiScreen();
}

class _DiaChiScreen extends State<DiaChiScreen> {
  final UserApiService _apiService = UserApiService();
  String _userId = '';
  DiaChi _diaChi = DiaChi(
    tinhThanhPho: 'Chưa cập nhật',
    quanHuyen: 'Chưa cập nhật',
    phuongXa: 'Chưa cập nhật',
    duongThon: 'Chưa cập nhật',
  );
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
          _diaChi = user.diaChi ?? _diaChi;
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
          Text('Tỉnh/Thành phố: ${_diaChi.tinhThanhPho}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Quận/Huyện: ${_diaChi.quanHuyen}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Phường/Xã: ${_diaChi.phuongXa}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Đường/Thôn: ${_diaChi.duongThon}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
