// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class HomeThumua extends StatefulWidget {
  const HomeThumua({super.key});

  @override
  State<HomeThumua> createState() => _HomeThumuaState();
}

class _HomeThumuaState extends State<HomeThumua> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: Color.fromRGBO(59, 99, 53, 1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 100,
                          width: 200,
                          child: Image.asset(
                            'lib/assets/logo_xinchao.png',
                            fit: BoxFit.contain,
                          )),
                      GestureDetector(
                        onTap: () {
                          print('Setting');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: Image.asset('lib/assets/caidat_icon.png'),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: Image.asset('lib/assets/fb_icon.png',
                          fit: BoxFit.cover),
                    ),
                    Container(
                      height: 55,
                      width: 300,
                      decoration: BoxDecoration(
                          border: Border.fromBorderSide(BorderSide(
                              color: Color.fromARGB(255, 184, 182, 182))),
                          borderRadius: BorderRadius.circular(50)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đăng bài viết của bạn.',
                              style: TextStyle(
                                fontSize: 15,
                                color: const Color.fromARGB(255, 158, 156, 156),
                              ),
                            ),
                            Icon(Icons.camera_alt_outlined),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //tin

              //Posts
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.fromBorderSide(BorderSide(
                          color: const Color.fromARGB(255, 146, 145, 145))),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(3, 5),
                            blurRadius: 1,
                            spreadRadius: 2)
                      ]),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 25),
                        child: Row(
                          children: [
                            Image.asset('lib/assets/logo_app.png'),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HiHi'),
                                  Text('online 1 năm trước'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        child: Text(
                            'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy. '),
                      ),
                      Container(
                          height: 200,
                          width: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              'lib/assets/avt2.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 20),
                        child: Row(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Icon(Icons.thumb_up_outlined),
                                  Text("120"),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.comment_outlined),
                                    Text("120"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(thickness: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                               Padding(
                                 padding: const EdgeInsets.only(right: 10),
                                 child: Image.asset('lib/assets/logo_app.png'),
                               ),
                               Expanded(
                                 child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Bình luận công khai'
                                  ),
                                 ),
                               )
                            ],
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
