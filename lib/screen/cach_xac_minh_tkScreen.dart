import 'package:flutter/material.dart';

class CachXacMinhTkscreen extends StatelessWidget {
  final String email;

  CachXacMinhTkscreen({required this.email});

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
              'lib/assets/arrow_back.png', // Đường dẫn đến hình ảnh icon quay lại
              width: 30,
              height: 30,
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title:       Text(
              'Xác minh tài khoản',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:const Color.fromARGB(255, 41, 87, 35),
              ),
            ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              'Để tăng cường bảo mật cho tài khoản của bạn, hãy xác minh thông tin bằng một trong những cách sau.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/otpxacminhtk',
                    arguments: email, // Sử dụng email đã được truyền từ trước
                  );

                  print("Gửi mã OTP tới: $email");
                },
                icon: Icon(Icons.email),
                label: Text('Xác minh bằng mã OTP gửi qua email'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: BorderSide(color: Colors.black),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
