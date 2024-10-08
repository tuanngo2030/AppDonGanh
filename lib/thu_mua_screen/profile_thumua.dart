// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ProfileThumua extends StatefulWidget {
  const ProfileThumua({super.key});

  @override
  State<ProfileThumua> createState() => _ProfileThumuaState();
}

class _ProfileThumuaState extends State<ProfileThumua> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              child: ImageIcon(
                AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
                size: 49, // Kích thước hình ảnh
              ),
            ),
          ),
        ),
        title: Text('Trang cá nhân'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.fromBorderSide(BorderSide(
                                color: Color.fromRGBO(47, 88, 42, 1), width: 2))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image.asset(
                            'lib/assets/avt2.jpg',
                            fit: BoxFit.cover,
                          ),
                        )),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Color.fromRGBO(47, 88, 42, 1),
                              border: Border.all(color: Colors.white, width: 1)),
                          child: Icon(
                            Icons.control_point_outlined,
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Nguyen Thi A',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color.fromRGBO(47, 88, 42, 1)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '45',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Bài viết',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '4589',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Người theo dõi',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '150',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Đang theo dõi',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 15),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bạn bè',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                      )),
                ),
          
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.fromBorderSide(
                          BorderSide(color: Colors.grey, width: 1))),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.fromBorderSide(BorderSide(
                                  color: Color.fromRGBO(47, 88, 42, 1), width: 2))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'lib/assets/avt1.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Vợ 1',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                            child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Container(
                                    height: 23,
                                    width: 23,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 15,
                                      color: Color.fromRGBO(41, 87, 35, 1),
                                    )
                                  ),
                                ),
                                label: Text(
                                  'Theo dõi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                )
                              )
                            ),
                      )
                    ],
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 15),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chức năng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                      )
                    ),
                ),
          
          
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15 , vertical: 10),
                  child: Container(
                    height: 420,
                    width: double.infinity,
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: [
                        MainFuntion(icon: Icon(Icons.person), title: 'Thông tin tài khoản', subtitle: 'Bao gồm thông tin cá nhân:'),
                        MainFuntion(icon: Icon(Icons.person), title: 'Thông tin tài khoản', subtitle: 'Bao gồm thông tin cá nhân:'),
                         MainFuntion(icon: Icon(Icons.person), title: 'Thông tin tài khoản', subtitle: 'Bao gồm thông tin cá nhân:'),
                        MainFuntion(icon: Icon(Icons.person), title: 'Thông tin tài khoản', subtitle: 'Bao gồm thông tin cá nhân:')
                      ],
                    ),
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){}, 
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Color.fromRGBO(217,217,217,1),
                        foregroundColor: Color.fromRGBO(41, 87, 35, 1),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


 Widget MainFuntion({
    required Icon icon,
    required String title,
    required String subtitle,
  }){
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(217, 217, 217, 1)
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  subtitle,
                   style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              )
                
            ],
          ),
        ),
      ),
    );
  }

}

 
