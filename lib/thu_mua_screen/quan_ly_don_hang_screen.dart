import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/thu_mua_screen/quan_ly_don_hang_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuanLyDonHangScreen extends StatefulWidget {
  const QuanLyDonHangScreen({super.key});

  @override
  State<QuanLyDonHangScreen> createState() => _QuanLyDonHangScreenState();
}

class _QuanLyDonHangScreenState extends State<QuanLyDonHangScreen> {
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
        orderModel = OrderApiService().fetchOrderForHoKinhDoanhId(
            userId!); // Fetch orders when userId is available
      });
    } else {
      setState(() {
        orderModel =
            Future.value([]); // Initialize with an empty list if no userId
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // 5 tabs for 5 different statuses
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
//nút
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'lib/assets/arrow_back.png',
                  width: 30,
                  height: 30,
                  color: const Color.fromRGBO(41, 87, 35, 1),
                ),
              ),
            ),
//
            title: const Text(
            'Đơn hàng',
            style: TextStyle(
                color: Color.fromRGBO(41, 87, 35, 1),
                fontWeight: FontWeight.bold),
          ),
            centerTitle: true,
            bottom: const TabBar(
              isScrollable: true,
              indicatorColor: Color.fromARGB(255, 41, 87, 35),
              labelColor: Color.fromARGB(255, 41, 87, 35),
              unselectedLabelColor: Color.fromARGB(255, 0, 0, 0),
              tabs: [
                Tab(text: 'Tất cả'),
                Tab(text: 'Đặt hàng'),
                Tab(text: 'Đóng gói'),
                Tab(text: 'Bắt đầu giao'),
                Tab(text: 'Hoàn thành'),
                Tab(text: 'Đã hủy'),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<List<OrderModel>>(
              future: orderModel,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(41, 87, 35, 1))));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không tìm thấy đơn hàng'));
                }

                List<OrderModel> orders = snapshot.data!;
                return TabBarView(
                  children: [
                    _buildOrderList(orders), // Tất cả
                    _buildOrderListByStatus(orders, 0), // Đặt hàng
                    _buildOrderListByStatus(orders, 1), // Đóng gói
                    _buildOrderListByStatus(orders, 2), // Bắt đầu giao
                    _buildOrderListByStatus(orders, 3), // Hoàn thành
                    _buildOrderListByStatus(orders, 4), // Đã hủy
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Widget to display all orders
  Widget _buildOrderList(List<OrderModel> orders) {
    return _buildListView(orders);
  }

  // Widget to display orders filtered by status
  Widget _buildOrderListByStatus(List<OrderModel> orders, int status) {
    List<OrderModel> filteredOrders =
        orders.where((order) => order.TrangThai == status).toList();
    return _buildListView(filteredOrders);
  }

  // ListView builder for order list
  Widget _buildListView(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng trong mục này'));
    }

    // Sắp xếp đơn hàng theo NgayTao giảm dần
    orders.sort((a, b) => b.NgayTao.compareTo(a.NgayTao));

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        DateTime orderDate = orders[index].NgayTao;
        String formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuanLyDonHangDetailScreen(
                  hoadonId: orders[index].id,
                ),
              ),
            );
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
                          orders[index].id,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 155, 154, 154)),
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
                                color: Color.fromARGB(255, 155, 154, 154),
                              ),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'vi', symbol: '₫')
                                  .format(orders[index].TongTien),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Tổng tiền: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 155, 154, 154),
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'vi', symbol: '₫')
                                    .format(orders[index].TongTien),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Đã khuyến mãi: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 155, 154, 154),
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'vi', symbol: '₫')
                                    .format(orders[index].SoTienKhuyenMai),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(41, 87, 35, 1),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            TrangThai(orders[index].TrangThai),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
