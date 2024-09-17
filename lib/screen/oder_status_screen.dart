// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class OderStatusScreen extends StatefulWidget {
  const OderStatusScreen({super.key});

  @override
  State<OderStatusScreen> createState() => _OderStatusScreenState();
}

class _OderStatusScreenState extends State<OderStatusScreen> {
  int status = 0;

  Color _getColor(int step) {
    return (step <= status) ? Color.fromRGBO(41, 87, 35, 1) : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Trạng thái đơn hàng',
            style: TextStyle(
              color: Color.fromRGBO(59, 99, 53, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(27),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin vận chuyển',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngày giao hàng dự kiến'),
                      Text('02-10-2023'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mã đơn hàng'),
                      Text('DGDK908897788'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                 Text(
                  'Tình trạng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                      child: Row(
                    children: [
                      Column(
                        children: [
                          // qua trinh
                          Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:
                                        const Color.fromRGBO(59, 99, 53, 1)),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ],
                          ),
                  
                          //thanh doc
                          Container(
                            height: 60,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                          ),
                          // qua trinh
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey),
                            child: Icon(Icons.check,color: Colors.white),
                          ),
                  
                          //thanh doc
                          Container(
                            height: 60,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                          ),
                          // qua trinh
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey),
                            child: Icon(Icons.check,color: Colors.white),
                          ),
                  
                          //thanh doc
                          Container(
                            height: 60,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                          ),
                          // qua trinh
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color:  Colors.grey),
                            child: Icon(Icons.check,color: Colors.white),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đặt hàng',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '02-10-2023',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 55),
                            Text(
                              'Đóng gói',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '02-10-2023',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 55),
                            Text(
                              'Bắt đầu giao',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '02-10-2023',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 55),
                            Text(
                              'Hoàn thành đơn hàng',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '02-10-2023',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      //icon process
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset('lib/assets/ic_oder.png'),
                              SizedBox(height: 55),
                              Image.asset('lib/assets/ic_pack.png'),
                              SizedBox(height: 55),
                              Image.asset('lib/assets/ic_delivery.png'),
                              SizedBox(height: 55),
                              Image.asset('lib/assets/ic_successoder.png'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                ),

              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Text(
                          'Đánh giá sản phẩm',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(59, 99, 53, 1),
                        foregroundColor: Colors.white
                      ),
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
}
