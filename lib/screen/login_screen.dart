import 'package:don_ganh_app/api_services/login_with_api_google.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserApiService _apiService = UserApiService(); // Khởi tạo dịch vụ API
  final LoginWithApiGoogle _apiGoogle = LoginWithApiGoogle();
  // Biến trạng thái lỗi
  String? _emailError;
  String? _passwordError;

  Future<void> _login() async {
  final String gmail =
      _emailController.text.trim(); // Loại bỏ khoảng trắng thừa
  final String matKhau = _passwordController.text.trim();

  setState(() {
    _emailError = null;
    _passwordError = null;
  });

  if (gmail.isEmpty || matKhau.isEmpty) {
    setState(() {
      if (gmail.isEmpty) _emailError = 'Vui lòng nhập email.';
      if (matKhau.isEmpty) _passwordError = 'Vui lòng nhập mật khẩu.';
    });
    return;
  }

  try {
    final NguoiDung? user = await _apiService.login(gmail, matKhau);
    print('Response from API: $user');
    if (user != null) {
      // Lưu thông tin người dùng vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('tenNguoiDung', user.tenNguoiDung ?? '');
      await prefs.setString('userId', user.id ?? '');

      // Điều hướng đến màn hình khác sau khi đăng nhập thành công
      Navigator.pushNamed(context, '/ban_la');
    } else {
      // Hiển thị lỗi khi đăng nhập không thành công
      setState(() {
        _emailError = 'Email hoặc mật khẩu không chính xác.';
      });
    }
  } catch (e) {
    // Xử lý lỗi
    setState(() {
      _emailError = 'Có lỗi xảy ra. Vui lòng thử lại sau.';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Đăng nhập",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                  Text(
                    "Chào mừng bạn trở lại với Đòn Gánh",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  )
                ],
              ),
            ),

            // email input
            Padding(
              padding: const EdgeInsets.all(15.0),
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
                        borderRadius: BorderRadius.circular(50),
                      ),
                      hintText: "abc@gmail.com",
                      errorText: _emailError, // Hiển thị lỗi ở đây
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            // password input
            Padding(
              padding: const EdgeInsets.all(15.0),
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
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      hintText: "Nhập mật khẩu",
                      errorText: _passwordError, // Hiển thị lỗi ở đây
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/Sendotpgmail');
                            // TODO: Implement password reset logic here
                          },
                          child: const Text(
                            "Quên mật khẩu ?",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(248, 158, 25, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // login button
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: _login,
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
                  "Đăng nhập",
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
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      signIn();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset('lib/assets/gg_icon.png'),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print("Login with twitter");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset('lib/assets/tw_icon.png'),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Bạn chưa có tài khoản ? ",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Go to register");
                        Navigator.pushNamed(context, '/registerscreen');
                      },
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(248, 158, 25, 1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Future<void> signIn() async {
  final user = await LoginWithApiGoogle.login();
  
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập thất bại')));
    return;
  } 

  try {
    // Gọi API để đăng ký người dùng Google
    await _apiGoogle.registerUserGoogle(user.displayName ?? '', user.email, user.id);

    // Lưu thông tin người dùng vào SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDisplayName', user.displayName ?? '');
    await prefs.setString('userEmail', user.email);
    await prefs.setString('googleId', user.id);
ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập thành công')),
    );
    // Điều hướng đến màn hình BanLa
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const BanLa()),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $error')));
  }
}


}


