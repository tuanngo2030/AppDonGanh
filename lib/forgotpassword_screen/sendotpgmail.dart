import 'package:don_ganh_app/api_services/forgotpassword_api.dart';
import 'package:don_ganh_app/forgotpassword_screen/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/screen/cach_xac_minh_tkScreen.dart'; // Import file API

class Sendotpgmail extends StatefulWidget {
  @override
  _Sendotpgmail createState() => _Sendotpgmail();
}

class _Sendotpgmail extends State<Sendotpgmail> {
  bool isSubscribed = false;
  final TextEditingController _emailController = TextEditingController();
 String? _errorMessage; // Biến lưu thông báo lỗi

  void _validateAndSubmit() async {
    String email = _emailController.text.trim();

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _errorMessage = 'Email không hợp lệ';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await ForgotpasswordApi.sendOtpForgotPassword(email);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(email: email),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi khi gửi OTP. Vui lòng thử lại.';
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
          'Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(41, 87, 35, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  icon: Image.asset(
                    'lib/assets/icongmail.png',
                    width: 30,
                    height: 30,
                    color: const Color.fromRGBO(41, 87, 35, 1),
                  ),
                  hintText: 'Nhập email của bạn',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _errorMessage, // Hiển thị lỗi
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Tiếp theo',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: isSubscribed,
                    onChanged: (value) {
                      setState(() {
                        isSubscribed = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Gửi tôi thông tin sản phẩm mới, sản phẩm hot, chương trình khuyến mãi và cập nhật mới nhất của Đòn Gánh',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
