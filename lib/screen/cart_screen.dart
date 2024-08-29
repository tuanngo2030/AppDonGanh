import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
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

  Future<ProductModel> fetchProduct(String productID) async {
    return await ProductApiService().getProductByID(productID);
  }

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
      body: FutureBuilder<CartModel>(
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
              ...cart.chiTietGioHang
                  .map((item) => FutureBuilder<ProductModel>(
                        future: fetchProduct(item.variantModel.idProduct),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (productSnapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text('Lỗi: ${productSnapshot.error}')),
                            );
                          } else if (!productSnapshot.hasData ||
                              productSnapshot.data == null) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text('Không tìm thấy sản phẩm')),
                            );
                          }

                          ProductModel product = productSnapshot.data!;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              product.imageProduct),
                                          fit: BoxFit.cover)),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Sản phẩm: ${product.nameProduct}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text('Số lượng: ${item.soLuong}'),
                                    Text('Đơn giá: ${item.donGia}'),
                                    
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        },
                      ))
                  .toList(),
            ],
          );
        },
      ),
    );
  }
}
