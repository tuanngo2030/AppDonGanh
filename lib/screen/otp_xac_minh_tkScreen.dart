import 'package:don_ganh_app/api_services/otp_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpXacMinhTkscreen extends StatefulWidget {
  final String email;

  OtpXacMinhTkscreen({required this.email});
  @override
  _OtpXacMinhTkscreen createState() => _OtpXacMinhTkscreen();
}

class _OtpXacMinhTkscreen extends State<OtpXacMinhTkscreen> {
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();
  final TextEditingController _otpController5 = TextEditingController();
  final TextEditingController _otpController6 = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();
  final OtpApiService _otpApiService = OtpApiService();

  void _verifyOtp() async {
    String otp = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text +
        _otpController5.text +
        _otpController6.text;

    try {
      bool isVerified = await _otpApiService.verifyOtp(otp, widget.email);
      print('OTP entered: $otp');
      print('API verification result: $isVerified');

      if (isVerified) {
        Navigator.pushNamed(
          context,
          '/loginscreen',
          arguments: isVerified,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verification failed! Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }

  void _resendOtp() async {
    // Add OTP resend logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP đã được gửi lại tới email của bạn.'),
      ),
    );
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
          'Nhập mã xác minh',
          style: TextStyle(
            fontSize: 18,
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
            children: [
              Text(
                'Mã xác thực đã được gửi đến Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(248, 158, 25, 1),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpTextField(_otpController1, _focusNode1, _focusNode2),
                  _otpTextField(_otpController2, _focusNode2, _focusNode3),
                  _otpTextField(_otpController3, _focusNode3, _focusNode4),
                  _otpTextField(_otpController4, _focusNode4, _focusNode5),
                  _otpTextField(_otpController5, _focusNode5, _focusNode6),
                  _otpTextField(_otpController6, _focusNode6, null),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: Text(
                  'Xác nhận',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(395, 55),
                  backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.all(10),
                  elevation: 5,
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _resendOtp,
                child: RichText(
                  text: TextSpan(
                    text: 'Bạn chưa nhận được mã OTP? ',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Gửi lại bây giờ',
                        style: TextStyle(
                          color: Color.fromRGBO(248, 158, 25, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpTextField(TextEditingController controller, FocusNode focusNode,
      FocusNode? nextFocusNode) {
    return Container(
      child: SizedBox(
        width: 40,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 41, 87, 35)),
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: "", // Ẩn bộ đếm ký tự
            border: UnderlineInputBorder(),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép số
          ],
          onChanged: (value) {
            if (value.length == 1 && nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else if (value.isEmpty && focusNode != _focusNode1) {
              FocusScope.of(context).previousFocus();
            }
          },
        ),
      ),
    );
  }
}
