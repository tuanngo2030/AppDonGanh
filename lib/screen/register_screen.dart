// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50),
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
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Tên đăng nhập",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      hintText: "example"),
                )
              ],
            ),
          ),

          //email input
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Email",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      hintText: "abc@gmail.com"),
                )
              ],
            ),
          ),

          //password input
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
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
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      hintText: "abc@gmail.com"),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Row(
                              children: [
                                Checkbox(value: false, onChanged: (p0) {}),
                                Text(
                                  "Tôi đồng ý với ",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                                Text(
                                  "Điều khoản ",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(248, 158, 25, 1)),
                                ),
                                Text(
                                  "& ",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                                Text(
                                  "Chính sách bảo mật ",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(248, 158, 25, 1)),
                                ),
                              ],
                            ))))
              ],
            ),
          ),

          //login button
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement login logic here
              },
              child: Text(
                "Đăng ký",
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
                  SizedBox(width: 10),
                  Text(
                    "Hoặc đăng nhập với",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
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
                      child: Image.asset('lib/assets/fb_icon.png'),
                      padding: EdgeInsets.all(20),
                    )),
                InkWell(
                    onTap: () {
                      print("Login with google");
                    },
                    child: Container(
                      child: Image.asset('lib/assets/gg_icon.png'),
                      padding: EdgeInsets.all(20),
                    )),
                InkWell(
                    onTap: () {
                      print("Login with twitter");
                    },
                    child: Container(
                      child: Image.asset('lib/assets/tw_icon.png'),
                      padding: EdgeInsets.all(20),
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
                    Text(
                      "Bạn đã có tài khoản ? ",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed((context), "/loginscreen");
                        print("Go to login");
                      },
                      child: Text(
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
      )),
    );
  }
}
