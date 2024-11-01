import 'package:don_ganh_app/api_services/login_with_api_google.dart';
import 'package:don_ganh_app/api_services/register_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _apiService = ApiService();
  bool _agreedToTerms = false;

  void _register() async {
  if (!_agreedToTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bạn cần đồng ý với điều khoản và chính sách')),
    );
    return;
  }

  NguoiDung newUser = NguoiDung(
    tenNguoiDung: _usernameController.text,
    gmail: _emailController.text,
    matKhau: _passwordController.text,
    soDienThoai: _phoneController.text,
    ngayTao: DateTime.now(),
    // Thêm các trường khác nếu cần thiết
  );

  bool isSuccess = await _apiService.registerUser(newUser);

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
                        hintText: "********"),
                    obscureText: true,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
              child: ElevatedButton(
                onPressed: _register,
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
                child: const Text(
                  "Đăng ký",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () {
                        print("Login with facebook");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset('lib/assets/fb_icon.png'),
                      )),
                  InkWell(
                      onTap: () async {
                      
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset('lib/assets/gg_icon.png'),
                      )),
                  InkWell(
                      onTap: () {
                        print("Login with twitter");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset('lib/assets/tw_icon.png'),
                      )),
                ],
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
