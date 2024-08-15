// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
       child: Column( 
        children: [
          Padding(
            padding: const EdgeInsets.all(60),
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

          //email input
          Padding(
            padding: const EdgeInsets.all(15.0),
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
            padding: const EdgeInsets.all(15.0),
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
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child:GestureDetector(
                              onTap: () {
                                  Navigator.pushNamed(context, '/forgot_password');
                                // TODO: Implement password reset logic here
                              },
                              child: Text(
                                "Quên mật khẩu ?",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(248, 158, 25, 1)),
                              ))))
                            )
                        
              ],
            ),
          ),

          //login button
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement login logic here
                 Navigator.pushNamed(context, '/ban_la');
              },
              child: Text(
                "Đăng nhập",
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
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Bạn chưa có tài khoản ? ",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Go to register");
                        Navigator.pushNamed(context, '/registerscreen');
                      },
                      child: Text(
                        "Đăng ký",
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
      )
    );
  }
}
