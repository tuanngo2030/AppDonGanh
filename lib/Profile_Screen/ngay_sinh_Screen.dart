import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NgaySinh extends StatefulWidget {
  const NgaySinh({super.key});

  @override
  State<NgaySinh> createState() => _NgaySinh();
}

class _NgaySinh extends State<NgaySinh> {
  final UserApiService _apiService = UserApiService();
  String _userId = '';
  String _ngaySinh = 'Chưa cập nhật';
  DateTime? _selectedDate;
  bool _isLoading = false; // Loading state variable
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
          _ngaySinh = user.ngaySinh ?? 'Chưa cập nhật';
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _ngaySinh = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _updateNgaySinh() async {
    if (_userId.isNotEmpty && _selectedDate != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      bool success = await _apiService.updateUserInformation(_userId, 'ngaySinh', _ngaySinh);

      if (success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('ngaySinh', _ngaySinh);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ngày sinh thành công')),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ngày sinh thất bại')),
        );
      }

      setState(() {
        _isLoading = false; // Hide loading indicator
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
          'Hồ sơ',
          style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1), fontWeight: FontWeight.bold),
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
              Text('Ngày sinh: $_ngaySinh', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // Button for selecting date
              SizedBox(
                width: double.infinity,  // Full width button
                height: 50,  // Height of the button
                child: ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: const Text(
                    'Chọn ngày sinh',
                    style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Button for updating date of birth with loading indicator
              SizedBox(
                width: double.infinity,  // Full width button
                height: 50,  // Height of the button
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateNgaySinh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Cập nhật Ngày sinh',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}