import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartModel>> _cartData;

  @override
  void initState() {
    super.initState();
    _cartData = _fetchCart();
  }

  Future<List<CartModel>> _fetchCart() async {
    CartApiService cartApiService = CartApiService();
    return await cartApiService.getGioHangByUserId();
  }

  Future<void> removeItem(String gioHangId, String variantId) async {
    try {
      await CartApiService().deleteFromCart(gioHangId, variantId);
      setState(() {
        _cartData = _fetchCart(); // Refresh cart data after removal
      });
    } catch (e) {
      print("Failed to remove item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
      ),
      body: FutureBuilder<List<CartModel>>(
        future: _cartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống.'));
          }

          List<CartModel> cartList = snapshot.data!;

          return ListView.builder(
            itemCount: cartList.length,
            itemBuilder: (context, index) {
              var cart = cartList[index];
              return Column(
                children: cart.mergedCart.map((item) {
                  return Card(
                    child: ListTile(
                      leading: Image.network(item.sanPham.imageProduct ?? ''),
                      title: Text(item.sanPham.nameProduct),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.chiTietGioHang.map((chiTiet) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mã sản phẩm: ${chiTiet.variantModel.sku}'),
                                Text('Giá: ${chiTiet.donGia}'),
                                Text('Số lượng: ${chiTiet.soLuong}'),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => removeItem(
                                    cart.id,
                                    chiTiet.variantModel.id, // Pass variantId
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
