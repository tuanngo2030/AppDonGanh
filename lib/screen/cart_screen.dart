import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<CartModel> cartModel;

  @override
  void initState() {
    super.initState();
    cartModel = CartApiService().getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
            child: Container(
              child: ImageIcon(
                AssetImage('lib/assets/arrow_back.png'),
                size: 49,
              ),
            ),
          ),
        ),
        title: Text(
          'Giỏ hàng',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color.fromRGBO(41, 87, 35, 1),
          ),
        ),
      ),
      body: Container(
        child: FutureBuilder<CartModel>(
          future: cartModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('Không tìm thấy dữ liệu'));
            }

            CartModel cart = snapshot.data!;

            return ListView(
              children: [
                Text(
                  'User ID: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ...cart.chiTietGioHang.map((item) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ID Biến Thể: '),
                      Text('Số lượng: ${item.soLuong}'),
                      Text('Đơn giá: ${item.donGia}'),
                    ],
                  ),
                )).toList(),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
