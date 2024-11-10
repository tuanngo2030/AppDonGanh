import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GioitinhScreen extends StatefulWidget {
  const GioitinhScreen({super.key});

  @override
  State<GioitinhScreen> createState() => _GioitinhScreen();
}

class _GioitinhScreen extends State<GioitinhScreen> {
  final UserApiService _apiService = UserApiService();
  String _userId = '';
  String _gioiTinh = 'Chưa cập nhật'; // Giá trị mặc định
  String? _selectedGioiTinh; // Giá trị giới tính mới được chọn
  bool _isLoading  = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      NguoiDung? user = await _apiService.fetchUserDetails(storedUserId);
      if (user != null) {
        setState(() {
          _userId = storedUserId;
          _gioiTinh = user.GioiTinh ?? 'Chưa cập nhật';
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _updateGioiTinh(String newGioiTinh) async {
    // if (_userId.isNotEmpty) {
    //   bool success = await _apiService.updateUserInformation(
    //       _userId, 'GioiTinh', newGioiTinh);
    //   setState(() {
    //     _gioiTinh = newGioiTinh;
    //   });

    //   if (success) {
    //     setState(() {
    //       _gioiTinh = newGioiTinh;
    //     });
      if (_userId.isNotEmpty && newGioiTinh != _gioiTinh) {
    setState(() {
      _isLoading = true; 
    });

    bool success = await _apiService.updateUserInformation(
        _userId, 'GioiTinh', newGioiTinh);

    setState(() {
      _isLoading = false; 
    });

    if (success) {
      setState(() {
        _gioiTinh = newGioiTinh; 
      });
        // Lưu giới tính mới vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('gioiTinh', newGioiTinh);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật giới tính thành công')));
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật giới tính thất bại')));
      }

      setState(() {
        _isLoading  = false;
      });
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
              color: const Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: const Text(
          'Giới tính',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
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
            Row(
              children: [
                const Text('Giới Tính: ', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  hint: Text(_gioiTinh, style: const TextStyle(fontSize: 16)),
                  value: _selectedGioiTinh,
                  items: ['Nam', 'Nữ', 'Khác'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGioiTinh = newValue;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
           
              SizedBox(
                width: double.infinity, // Full-width button
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedGioiTinh != null && !_isLoading 
                      ? () => _updateGioiTinh(_selectedGioiTinh!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Cập nhật giới tính',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            
          ],
        ),
      ),
    );
  }
}
