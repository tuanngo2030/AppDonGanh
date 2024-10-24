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
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mật khẩu mới',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 41, 87, 35)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Hãy nhập mật khẩu mới mà bạn muốn đặt.',
                style: TextStyle(fontSize: 10, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              // Trường nhập mật khẩu mới
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 10),
              // Trường xác nhận mật khẩu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 40),
              // Nút xác nhận
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_newPasswordController.text ==
                        _confirmPasswordController.text) {
                      _updatePassword(); // Gọi hàm cập nhật mật khẩu
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mật khẩu không khớp.')),
                      );
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
