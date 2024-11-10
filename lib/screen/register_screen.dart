import 'dart:math';

import 'package:don_ganh_app/api_services/login_with_api_google.dart';
import 'package:don_ganh_app/api_services/register_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  final _apiService = ApiService();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _passwordError;
  bool _obscurePassword = true;
  String _captcha = '';
  final LoginWithApiGoogle _apiGoogle = LoginWithApiGoogle();

  Future<void> signIn() async {
    final user = await LoginWithApiGoogle.login();

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng nhập thất bại')));
      return;
    }

    try {
      // Gọi API để đăng ký người dùng Google
      await _apiGoogle.registerUserGoogle(
          user.displayName ?? '', user.email, user.id);

      // Lưu thông tin người dùng vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDisplayName', user.displayName ?? '');
      await prefs.setString('userEmail', user.email);
      await prefs.setString('googleId', user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công')),
      );
      // Điều hướng đến màn hình BanLa
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BanLa()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $error')));
    }
  }

// Hàm kiểm tra độ mạnh của mật khẩu
  bool validatePassword(String password) {
    final passwordRegExp = RegExp(
        r'^(?=.*[A-Z])(?=.*\W).{7,}$'); // Ít nhất 7 ký tự, 1 chữ cái viết hoa và 1 ký tự đặc biệt
    return passwordRegExp.hasMatch(password);
  }

// Tạo CAPTCHA ngẫu nhiên
  void _generateCaptcha() {
    final random = Random();
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    setState(() {
      _captcha =
          List.generate(6, (_) => characters[random.nextInt(characters.length)])
              .join();
    });
  }

  _confirmRegister() {
    setState(() {
      _passwordError = null;
    });

    // Kiểm tra các trường thông tin
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên người dùng không được để trống')),
      );
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email không hợp lệ')),
      );
      return;
    }

    // Kiểm tra mật khẩu
    if (!validatePassword(_passwordController.text)) {
      setState(() {
        _passwordError =
            'Mật khẩu phải có ít nhất 7 ký tự, 1 chữ cái viết hoa,\n1 ký tự đặc biệt';
      });
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bạn cần đồng ý với điều khoản và chính sách')),
      );
      return;
    }

    _showCaptchaDialog();
  }

// Hàm xử lý đăng ký
  void _register() async {
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
      Navigator.pushNamed(
        context,
        '/xacminhtk',
        arguments: _emailController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại')),
      );
    }
  }

// Hiển thị hộp thoại CAPTCHA

  Future<void> _showCaptchaDialog() async {
    _generateCaptcha();
    _captchaController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          title: const Text(
            'Nhập mã CAPTCHA',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CAPTCHA container with gradient background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(228, 247, 207, 1),
                      Color.fromRGBO(59, 99, 53, 1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color.fromRGBO(59, 99, 53, 1), width: 1.5),
                ),
                child: Stack(
                  children: [
                    // Random lines for noise with enhanced animation
                    for (int i = 0; i < 50; i++)
                      Positioned(
                        top: Random().nextDouble() * 60,
                        left: Random().nextDouble() * 180,
                        child: Transform.rotate(
                          angle: Random().nextDouble() * pi / 2 - pi / 4,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: Random().nextDouble() * 50 + 20,
                            height: 1.5,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                    // Display CAPTCHA characters with custom rotation and offset
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _captcha.characters.map((char) {
                        final rotation = Random().nextDouble() * 0.3 - 0.15;
                        final verticalOffset = Random().nextDouble() * 6 - 3;
                        final horizontalOffset = Random().nextDouble() * 6 - 3;

                        return Transform.translate(
                          offset: Offset(horizontalOffset, verticalOffset),
                          child: Transform.rotate(
                            angle: rotation,
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors
                                    .primaries[Random()
                                        .nextInt(Colors.primaries.length)]
                                    .shade900,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _captchaController,
                decoration: const InputDecoration(
                  hintText: 'Nhập mã CAPTCHA',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_captchaController.text == _captcha) {
                  Navigator.of(context).pop();
                  _register();
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
                      errorText: _passwordError, // Hiển thị lỗi nếu có
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
                    obscureText:
                        _obscurePassword, // Điều khiển việc ẩn/hiện mật khẩu
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 15),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (bool? value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              "Tôi đồng ý với ",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            const Text(
                              "Điều khoản ",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(248, 158, 25, 1)),
                            ),
                            const Text(
                              "& ",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            const Text(
                              "Chính sách bảo mật ",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(248, 158, 25, 1)),
                            ),
                          ],
                        )))),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
              child: ElevatedButton(
                onPressed: () {
                  _confirmRegister();
                },
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
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 2,
                      width: 90,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Hoặc đăng nhập với",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 2,
                      width: 90,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 110, vertical: 20),
              child: InkWell(
                onTap: () {
                  signIn();
                },
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.fromBorderSide(
                          BorderSide(width: 1, color: Colors.grey))),
                  child: Row(
                    children: [
                      Container(
                          height: 70,
                          width: 70,
                          padding: const EdgeInsets.all(20),
                          child: Image.asset('lib/assets/gg_icon.png')),
                      const Text("Đăng nhập với Google")
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Bạn đã có tài khoản ? ",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/loginscreen");
                          print("Go to login");
                        },
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(248, 158, 25, 1),
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
