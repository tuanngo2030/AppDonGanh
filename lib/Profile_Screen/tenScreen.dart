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
  bool _isLoading = false; // Loading state variable

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');
     String? token = prefs.getString('token');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      NguoiDung? user = await UserApiService().fetchUserDetails(storedUserId, token!);
      if (user != null) {
        setState(() {
          _userId = storedUserId;
          _tenNguoiDung = user.tenNguoiDung ?? 'Chưa cập nhật';
          _tenNguoiDungController.text = _tenNguoiDung;
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _updateName(String newName) async {
    // Use the value from the controller or the existing name if not changed
    String newName = _selectedtenNguoiDung?.isNotEmpty == true
        ? _selectedtenNguoiDung!
        : _tenNguoiDung;

    if (_userId.isNotEmpty && newName != _tenNguoiDung) {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      bool success = await _apiService.updateUserInformation(
          _userId, 'tenNguoiDung', newName);

      setState(() {
        _isLoading = false; // Reset loading state
      });

      if (success) {
        setState(() {
          _tenNguoiDung = newName; // Update the displayed name
        });
        // Save new name to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('gmail', newName);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật họ và tên thành công')));
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật họ và tên thất bại')));
      }
    } else {
      // If the name is the same or userId is empty, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có thay đổi nào để cập nhật')));
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
          'Họ và tên',
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
            Column(
              children: [
                TextFormField(
                  controller: _tenNguoiDungController,
                  onChanged: (value) {
                    setState(() {
                      _selectedtenNguoiDung = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Nhập họ và tên',
                    labelStyle: const TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                          color: Colors.grey), // Màu viền khi không được chọn
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(41, 87, 35, 1)), // Màu viền khi được chọn
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: _tenNguoiDung,
                    counterText: '${_tenNguoiDung.length}/30',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  keyboardType: TextInputType.name,
                  maxLength: 30,
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedtenNguoiDung != null && !_isLoading
                    ? () => _updateName(_selectedtenNguoiDung!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                ),
                // onPressed: _isLoading
                //     ? null // Disable button if loading
                //     : _updateName, // Call the updated method without parameters
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white) // Show loading indicator
                    : const Text('Cập nhật họ và tên',
                        style:
                            TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
