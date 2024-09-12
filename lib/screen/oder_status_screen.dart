import 'package:flutter/material.dart';

class OderStatusScreen extends StatefulWidget {
  const OderStatusScreen({super.key});

  @override
  State<OderStatusScreen> createState() => _OderStatusScreenState();
}

class _OderStatusScreenState extends State<OderStatusScreen> {
  int status = 0;

  Color _getColor(int step){
    return (step <= status) ? Color.fromRGBO(59, 99, 53, 1) : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trạng thái đơn hàng'),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin vận chuyển'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ngày giao hàng dự kiến'),
                  Text('02-10-2023'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mã đơn hàng'),
                  Text('DGDK908897788'),
                ],
              ),
              Text('Tình trạng'),
              Container(
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
                                color: const Color.fromARGB(255, 144, 143, 143)),
                            child: Icon(Icons.vpn_lock),
                          ),
                        ],
                      ),

                      //thanh doc
                      Container(
                        height: 60,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
                      // qua trinh
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color.fromARGB(255, 144, 143, 143)),
                        child: Icon(Icons.vpn_lock),
                      ),

                      //thanh doc
                      Container(
                        height: 60,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
                      // qua trinh
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color.fromARGB(255, 144, 143, 143)),
                        child: Icon(Icons.vpn_lock),
                      ),

                      //thanh doc
                      Container(
                        height: 60,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
                      // qua trinh
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color.fromARGB(255, 144, 143, 143)),
                        child: Icon(Icons.vpn_lock),
                      ),
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
