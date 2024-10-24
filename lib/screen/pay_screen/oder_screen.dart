import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/screen/oder_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OderScreen extends StatefulWidget {
  const OderScreen({super.key});

  @override
  State<OderScreen> createState() => _OderScreenState();
}

class _OderScreenState extends State<OderScreen> {
  late Future<List<OrderModel>> orderModel =
      Future.value([]); // Initialize with an empty Future
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load userId
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      setState(() {
        orderModel = OrderApiService()
            .fetchOrder(userId!); // Fetch orders when userId is available
      });
    } else {
      // Handle the case where userId is null
      // For example, navigate to a login screen or show an error message
      setState(() {
        orderModel =
            Future.value([]); // Initialize with an empty list if no userId
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              FutureBuilder<List<OrderModel>>(
                future: orderModel,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không tìm thấy đơn hàng'));
                  }

                  List<OrderModel> order = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: order.length,
                      itemBuilder: (context, index) {
                        DateTime orderDate = order[index].NgayTao;

                        // Format date
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
                                          order[index].id,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 15),
                                        )),
                                        const SizedBox(width: 8),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color.fromARGB(
                                                  255, 155, 154, 154)),
                                        )
                                      ],
                                    ),
                                  ),
                                  const Divider(thickness: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Row(
                                          children: [
                                            const Text(
                                              'Số lượng: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 155, 154, 154)),
                                            ),
                                            Text(
                                              '${order[index].TongTien}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Tổng tiền: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(
                                                  255, 155, 154, 154)),
                                        ),
                                        Text(
                                          '${order[index].TongTien}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: ElevatedButton(
                                            onPressed:
                                                () {}, // Handle detail action here
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      41, 87, 35, 1),
                                              foregroundColor: Colors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
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
                                            child: const Text(
                                              'Detail',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text(
                                            TrangThai(order[index].TrangThai),
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
                },
              ),
            ],
          ),
        ),
      ),
    );
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
      case 4:
        return 'Đã hủy đơn hàng';
      default:
        return 'Không xác định';
    }
  }
}
