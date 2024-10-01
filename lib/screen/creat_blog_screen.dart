import 'package:flutter/material.dart';

class CreatBlogScreen extends StatefulWidget {
  const CreatBlogScreen({super.key});

  @override
  State<CreatBlogScreen> createState() => _CreatBlogScreenState();
}

class _CreatBlogScreenState extends State<CreatBlogScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(59, 99, 53, 1),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                border: Border.fromBorderSide(BorderSide(
                                    color: Color.fromRGBO(59, 99, 53, 1),
                                    width: 2)),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100)),
                            child: Icon(
                              Icons.arrow_back,
                              color: Color.fromRGBO(59, 99, 53, 1),
                            )),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              "Tạo bài viết",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Đăng",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                foregroundColor: Color.fromRGBO(59, 99, 53, 1),
                                backgroundColor: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
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
          
                TextFormField(
                    maxLines: 15,
                    minLines: 13,
                  decoration: InputDecoration(
                    hintText: "Đăng bài viết của bạn.",
                    labelStyle: TextStyle(fontSize: 16),
                    contentPadding: EdgeInsets.all(25),
                  ),
                  
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
