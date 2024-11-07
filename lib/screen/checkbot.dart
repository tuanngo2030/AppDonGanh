import 'dart:math';
import 'package:don_ganh_app/api_services/login_with_api_google.dart';
import 'package:don_ganh_app/api_services/register_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';

class Checkbot extends StatefulWidget {
  const Checkbot({super.key});

  @override
  State<Checkbot> createState() => _CheckbotState();
}

class _CheckbotState extends State<Checkbot> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  final _apiService = ApiService();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _passwordError;
  bool _obscurePassword = true;
  String _captcha = ''; // CAPTCHA string

  // Hàm kiểm tra độ mạnh của mật khẩu
  bool validatePassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\W).{7,}$');
    return passwordRegExp.hasMatch(password);
  }

  // Tạo CAPTCHA ngẫu nhiên
  void _generateCaptcha() {
    final random = Random();
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    setState(() {
      _captcha = List.generate(6, (_) => characters[random.nextInt(characters.length)]).join();
    });
  }

  // Hiển thị hộp thoại CAPTCHA
  Future<void> _showCaptchaDialog() async {
    _generateCaptcha(); // Tạo CAPTCHA mới
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập mã CAPTCHA'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Vui lòng nhập mã CAPTCHA sau: $_captcha'),
              TextField(
                controller: _captchaController,
                decoration: const InputDecoration(hintText: 'Nhập mã CAPTCHA'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (_captchaController.text == _captcha) {
                  Navigator.of(context).pop();
                  _register(); // Gọi hàm đăng ký nếu CAPTCHA đúng
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CAPTCHA không đúng')),
                  );
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  // Hàm xử lý đăng ký
  void _register() async {
    setState(() {
      _passwordError = null;
    });

    if (!validatePassword(_passwordController.text)) {
      setState(() {
        _passwordError = 'Mật khẩu phải có ít nhất 7 ký tự, 1 chữ cái viết hoa,\n1 ký tự đặc biệt';
      });
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đồng ý với điều khoản và chính sách')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    NguoiDung newUser = NguoiDung(
      tenNguoiDung: _usernameController.text,
      gmail: _emailController.text,
      matKhau: _passwordController.text,
      ngayTao: DateTime.now(),
    );

    bool isSuccess = await _apiService.registerUser(newUser);

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công')),
      );
      Navigator.pushNamed(
        context,
        '/xacminhtk',
        arguments: _emailController.text,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Đăng ký",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "Điền thông tin của bạn bên dưới hoặc đăng ký bằng tài khoản xã hội của bạn.",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Tên đăng nhập",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(41, 87, 35, 1)),
                    ),
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        hintText: "example"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Email",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(41, 87, 35, 1)),
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        hintText: "abc@gmail.com"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Mật khẩu",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(41, 87, 35, 1),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      hintText: "********",
                      errorText: _passwordError,
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
                    ),
                    obscureText: _obscurePassword,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _showCaptchaDialog,
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(395, 55),
                  backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(10),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        "Đăng ký",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            // Phần checkbox đồng ý điều khoản và chính sách
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Tôi đồng ý với điều khoản và chính sách bảo mật của ứng dụng",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
