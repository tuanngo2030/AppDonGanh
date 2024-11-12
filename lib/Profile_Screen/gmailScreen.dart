import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Gmailscreen extends StatefulWidget {
  const Gmailscreen({super.key});

  @override
  State<Gmailscreen> createState() => _Gmailscreen();
}

class _Gmailscreen extends State<Gmailscreen> {
  final UserApiService _apiService = UserApiService();
  String _userId = '';
  String _gmail = 'Chưa cập nhật';
  final TextEditingController _gmailController = TextEditingController();
  String? _selectedGmail;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Loading state variable

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
          _gmail = user.gmail ?? 'Chưa cập nhật';
          _gmailController.text =
              _gmail; // Prepopulate the text field with the existing Gmail
        });
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _updateGmail(String newGmail) async {
    if (_userId.isNotEmpty) {
         setState(() {
        _isLoading = true; // Show loading indicator
      });

      bool success =
          await _apiService.updateUserInformation(_userId, 'gmail', newGmail);

      if (success) {
        setState(() {
          _gmail = newGmail;
        });
        // Lưu gmail mới vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('gmail', newGmail);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Cập nhật gmail thành công')));
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Cập nhật gmail thất bại')));
      }
         setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  String? _validateGmail(String? value) {
    // Regular expression to validate email format
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    final regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    } else if (!regExp.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
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
          'Email',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  TextFormField(
                    controller:
                        _gmailController, // Prepopulate with the existing email
                    onChanged: (value) {
                      setState(() {
                        _selectedGmail = value;
                      });
                    },
                    validator: (value) {
                      if (value != _gmail) {
                        // Only validate if the email has changed
                        return _validateGmail(value);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nhập email',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25.0), // Rounded corners
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Colors.grey), // Màu viền khi không được chọn
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(
                                41, 87, 35, 1)), // Màu viền khi được chọn
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Nhập email của bạn',
                      counterText:
                          'Tối đa 100 ký tự', // Custom character limit hint
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20), // Padding inside the field
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 100,
                  )
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedGmail != null && !_isLoading
                      ? () => _updateGmail(_selectedGmail!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                  ),
                  // onPressed: () {
                  //   if (_formKey.currentState?.validate() == true) {
                  //     _updateGmail(_selectedGmail!);
                  //   }
                  // },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cập nhật Gmail',
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
