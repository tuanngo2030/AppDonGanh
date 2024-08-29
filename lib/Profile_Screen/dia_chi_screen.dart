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

  final TextEditingController _tinhThanhPhoController = TextEditingController();
  final TextEditingController _quanHuyenController = TextEditingController();
  final TextEditingController _phuongXaController = TextEditingController();
  final TextEditingController _duongThonController = TextEditingController();

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
          _tinhThanhPhoController.text = _diaChi.tinhThanhPho;
          _quanHuyenController.text = _diaChi.quanHuyen;
          _phuongXaController.text = _diaChi.phuongXa;
          _duongThonController.text = _diaChi.duongThon;
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

Future<void> _updateAddress() async {
  // Kiểm tra xem các trường có dữ liệu không
  if (_tinhThanhPhoController.text.isEmpty ||
      _quanHuyenController.text.isEmpty ||
      _phuongXaController.text.isEmpty ||
      _duongThonController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vui lòng điền đầy đủ thông tin địa chỉ.'),
      ),
    );
    return;
  }

  // Tạo đối tượng DiaChi mới với các giá trị đã cập nhật
  DiaChi updatedDiaChi = DiaChi(
    tinhThanhPho: _tinhThanhPhoController.text,
    quanHuyen: _quanHuyenController.text,
    phuongXa: _phuongXaController.text,
    duongThon: _duongThonController.text,
  );

  try {
    bool isUpdated = await _apiService.updateUserAddress(_userId, updatedDiaChi);

    if (isUpdated=true) {
      setState(() {
        _diaChi = updatedDiaChi;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Địa chỉ đã được cập nhật!'),
        ),
      );
       await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật địa chỉ thất bại. Vui lòng thử lại.'),
        ),
      );
    }
  } catch (e) {
    print('Error updating address: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xảy ra lỗi. Vui lòng thử lại sau.'),
      ),
    );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextField(
                controller: _tinhThanhPhoController,
                decoration: InputDecoration(labelText: 'Tỉnh/Thành phố'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _quanHuyenController,
                decoration: InputDecoration(labelText: 'Quận/Huyện'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _phuongXaController,
                decoration: InputDecoration(labelText: 'Phường/Xã'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _duongThonController,
                decoration: InputDecoration(labelText: 'Đường/Thôn'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateAddress,
                child: Text('Cập nhật địa chỉ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.all(10),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
