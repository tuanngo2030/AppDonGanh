import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/screen/oder_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OderScreen extends StatefulWidget {
  const OderScreen({super.key});

  @override
  State<OderScreen> createState() => _OderScreenState();
}

class _OderScreenState extends State<OderScreen> {
  late Future<List<OrderModel>> orderModel;

  @override
  void initState() {
    super.initState();
    orderModel = OrderApiService().fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
            child: Column(
          children: [
            FutureBuilder<List<OrderModel>>(
                future: orderModel,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return Center(child: Text('Không tìm thấy hình ảnh'));
                  }

                  List<OrderModel> order = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: order.length,
                      itemBuilder: (context, index) {
                        DateTime orderDate = order[index].NgayTao;

                        // Định dạng ngày
                        String formattedDate =
                            DateFormat('dd/MM/yyyy').format(orderDate);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OderStatusScreen(
                                          orderModel: order[index],
                                        )));
                          },
                          child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          '${order[index].id}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                        SizedBox(width: 8),
                                        Text(
                                          '$formattedDate',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: const Color.fromARGB(
                                                  255, 155, 154, 154)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Row(
                                          children: [
                                            Text(
                                              'Số lượng: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color.fromARGB(
                                                      255, 155, 154, 154)),
                                            ),
                                            Text(
                                              '${order[index].TongTien}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tổng tiền: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: const Color.fromARGB(
                                                  255, 155, 154, 154)),
                                        ),
                                        Text(
                                          '${order[index].TongTien}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 100,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            child: Text(
                                              'Detail',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color.fromRGBO(41, 87, 35, 1),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text(
                                            '${TrangThai(order[index].TrangThai)}',
                                            textAlign: TextAlign.right,
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  );
                }),
          ],
        )),
      ),
    ));
  }

  String TrangThai(int trangThai) {
    switch (trangThai) {
      case 0:
        return 'Đặt hàng';
      case 1:
        return 'Đóng gói';
      case 2:
        return 'Bắt đầu giao';
      case 3:
        return 'Hoàn thành đơn hàng';
      default:
        return 'Không xác định';
    }
  }
}
