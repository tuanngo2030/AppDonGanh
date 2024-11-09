import 'package:don_ganh_app/api_services/resetpassword_api.dart';
import 'package:flutter/material.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  _ResetpasswordState createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ResetPasswordApi _resetPasswordApi = ResetPasswordApi();

  String? _emailError;
  String? _passwordError;

  bool validateEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  bool validatePassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\W).{7,}$');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _resetPassword() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final String gmail = _emailController.text.trim();
    final String matKhauMoi = _passwordController.text;

    if (gmail.isEmpty) {
      setState(() {
        _emailError = 'Vui lòng nhập email của bạn.';
      });
      return;
    } else if (!validateEmail(gmail)) {
      setState(() {
        _emailError = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
      });
      return;
    }

    if (matKhauMoi.isEmpty) {
      setState(() {
        _passwordError = 'Vui lòng nhập mật khẩu mới.';
      });
      return;
    } else if (!validatePassword(matKhauMoi)) {
      setState(() {
        _passwordError = 'Mật khẩu phải có ít nhất 7 ký tự, bao gồm chữ hoa và ký tự đặc biệt.';
      });
      return;
    }

    final success = await _resetPasswordApi.resetPassword(gmail, matKhauMoi);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu đã được reset thành công!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại.')),
      );
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
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          'Sửa mật khẩu',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              if (_emailError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0,left: 10.0),
                    child: Text(
                      _emailError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mật khẩu mới',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              if (_passwordError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0,left: 10.0),
                    child: Text(
                      _passwordError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 41, 87, 35),
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

