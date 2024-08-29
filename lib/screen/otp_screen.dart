import 'package:don_ganh_app/api_services/otp_api_service.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  final String email;

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  final OtpApiService _otpApiService = OtpApiService();

  OtpScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Code xác minh',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 41, 87, 35)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Hãy nhập code mà chúng tôi vừa gửi tới email của bạn',
                style: TextStyle(fontSize: 10, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Text(
                email, // Display the dynamic email
                style: TextStyle(
                    fontSize: 10, color: Color.fromARGB(255, 248, 159, 25)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OTPDigitTextField(
                    controller: _controller1,
                    currentNode: _focusNode1,
                    nextNode: _focusNode2,
                  ),
                  OTPDigitTextField(
                    controller: _controller2,
                    currentNode: _focusNode2,
                    previousNode: _focusNode1,
                    nextNode: _focusNode3,
                  ),
                  OTPDigitTextField(
                    controller: _controller3,
                    currentNode: _focusNode3,
                    previousNode: _focusNode2,
                    nextNode: _focusNode4,
                  ),
                  OTPDigitTextField(
                    controller: _controller4,
                    currentNode: _focusNode4,
                    previousNode: _focusNode3,
                  ),
                ],
              ),
              SizedBox(height: 50),
              Text(
                'Bạn chưa nhận được mã OTP',
                style: TextStyle(fontSize: 11, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Text(
                'Gửi lại code ( 0:59 )',
                style: TextStyle(
                    fontSize: 10, color: Color.fromARGB(255, 248, 159, 25)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    String otp = _controller1.text +
                        _controller2.text +
                        _controller3.text +
                        _controller4.text;

                    try {
                      bool isVerified =
                          await _otpApiService.verifyOtp(otp, email);
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
                            content: Text(
                                'OTP verification failed! Please try again.'),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Error during OTP verification: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'An error occurred. Please try again later.'),
                        ),
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

class OTPDigitTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentNode;
  final FocusNode? nextNode;
  final FocusNode? previousNode;

  OTPDigitTextField({
    required this.controller,
    required this.currentNode,
    this.nextNode,
    this.previousNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 69,
      height: 49,
      child: TextFormField(
        controller: controller,
        focusNode: currentNode,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 41, 87, 35)),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.all(0),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 41, 87, 35)),
            borderRadius: BorderRadius.circular(22),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 41, 87, 35)),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && nextNode != null) {
            nextNode?.requestFocus();
          } else if (value.isEmpty && previousNode != null) {
            previousNode?.requestFocus();
          }
        },
      ),
    );
  }
}