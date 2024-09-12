import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SodienthoaiScreen extends StatefulWidget {
  const SodienthoaiScreen({super.key});

  @override
  State<SodienthoaiScreen> createState() => _SodienthoaiScreen();
}

class _SodienthoaiScreen extends State<SodienthoaiScreen> {
  final UserApiService _apiService = UserApiService();
  String _userId = '';
  String _soDienThoai = '';  // Change to String
  final TextEditingController _soDienThoaiController = TextEditingController();
  String? _selectedSdt;
  final _formKey = GlobalKey<FormState>();

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
          _soDienThoai = user.soDienThoai?.toString() ?? '';  // Store phone number as string
          _soDienThoaiController.text = _soDienThoai;  // Set the controller to show the phone number
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _updateSoDienThoai(String newSdt) async {
    if (_userId.isNotEmpty) {
      bool success = await _apiService.updateUserInformation(
          _userId, 'soDienThoai', newSdt);

      if (success) {
        setState(() {
          _soDienThoai = newSdt;  // Update the phone number in the UI
        });
        // Save the new phone number to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('soDienThoai', newSdt);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật số điện thoại thành công')));
        Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật số điện thoại thất bại')));
      }
    }
  }

  String? _validateSoDienThoai(String? value) {
    const pattern =
        r'(^(?:[+0]9)?[0-9]{10,12}$)';
    final regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (value.length != 10) {
      return 'Số điện thoại phải có đúng 10 chữ số';
    }
    if (!value.startsWith('0')) {
      return 'Số điện thoại phải bắt đầu bằng số 0';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Số điện thoại phải là số';
    }
        if (!regex.hasMatch(value))
      return 'lỗi';
    else
    return null;
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _soDienThoaiController,
                onChanged: (value) {
                  setState(() {
                    _selectedSdt = value;
                  });
                },
                validator: _validateSoDienThoai,
                decoration: InputDecoration(
                  labelText: 'Nhập số điện thoại mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Nhập số điện thoại của bạn',
                  counterText: 'Tối đa 10 ký tự',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Padding inside the field
                ),
                keyboardType: TextInputType.number,
                maxLength: 10,  // Restrict to 10 digits
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,  // Full width button
                height: 50, 
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      _updateSoDienThoai(_selectedSdt!);
                    }
                  },
                  child: const Text('Cập nhật Số điện thoại', style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
