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
    final TextEditingController _tenNguoiDungController = TextEditingController();
  String? _selectedtenNguoiDung;
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
          _tenNguoiDungController.text=_tenNguoiDung;
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }
 Future<void> _updateName(String newName) async {
    if (_userId.isNotEmpty) {
      bool success =
          await _apiService.updateUserInformation(_userId, 'tenNguoiDung', newName);

      if (success) {
        setState(() {
          _tenNguoiDung = newName;
        });
        // Lưu gmail mới vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('gmail', newName);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật họ và tên thành công')));
        Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật họ và tên thất bại')));
      }
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
         Column(
                children: [
                  TextFormField(
                    controller: _tenNguoiDungController,  // Prepopulate with the existing email
                    onChanged: (value) {
                      setState(() {
                        _selectedtenNguoiDung = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Nhập họ và tên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0), // Rounded corners
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '$_tenNguoiDung',
                      counterText: 'Tối đa 100 ký tự', // Custom character limit hint
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Padding inside the field
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 100,
                  )
                ],
              ),
               const SizedBox(height: 20),
              SizedBox(
                 width: double.infinity,  // Full width button
                height: 50, 
                child: ElevatedButton(
                  onPressed: () {
                      _updateName(_selectedtenNguoiDung!);                
                  }, 
                  child: const Text('Cập nhật họ và tên', style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
