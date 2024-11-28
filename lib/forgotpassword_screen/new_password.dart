import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
Future<void> _updatePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gmail = prefs.getString('gmail'); // Lấy gmail từ SharedPreferences
    String? resetToken = prefs.getString('resetToken'); // Lấy resetToken

    if (_newPasswordController.text.isNotEmpty &&
        resetToken != null &&
        gmail != null) {
      final url = Uri.parse(
          '${dotenv.env['API_URL']}/user/SendPassword');

      try { 
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'gmail': gmail,
            'matKhauMoi': _newPasswordController.text,
            'resetToken': resetToken,
          }),
        );

        if (response.statusCode == 200) {
          // Xử lý khi cập nhật thành công
          print('Password updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mật khẩu đã được cập nhật thành công!')),
          );
         Navigator.pushNamed(context, '/loginscreen');
        } else {
          // Xử lý khi cập nhật không thành công
          print('Failed to update password: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật mật khẩu thất bại!')),
          );
        }
      } catch (error) {
        print('Error updating password: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi, vui lòng thử lại.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập mật khẩu mới và xác nhận.')),
      );
    }
  }
  bool _validatePassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[a-z]).{7,}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Mật khẩu mới',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 41, 87, 35)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Hãy nhập mật khẩu mới mà bạn muốn đặt.',
                style: TextStyle(fontSize: 10, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Mật khẩu mới',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  // Hiển thị lỗi dưới ô nhập
                  errorText: _passwordError,
                  errorStyle: const TextStyle(
                      color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Xác nhận mật khẩu mới',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_validatePassword(_newPasswordController.text)) {
                      setState(() {
                        _passwordError =
                            'Mật khẩu phải có ít nhất 7 ký tự, 1 chữ cái viết hoa và 1 ký tự đặc biệt.';
                      });
                      return;
                    }
                    if (_newPasswordController.text ==
                        _confirmPasswordController.text) {
                      setState(() {
                        _passwordError = null;
                      });
                      _updatePassword();
                    } else {
                      setState(() {
                        _passwordError = 'Mật khẩu không khớp.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 87, 35),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Xác nhận',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
