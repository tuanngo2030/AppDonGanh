import 'dart:math';

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
  late Future<CartModel> cartModelFuture;
  CartModel? cartModel; // Hold the cartModel locally
  List<bool> isChecked = []; // List to manage checkbox states

  @override
  void initState() {
    super.initState();
    // Fetch the cart once and store it locally
    cartModelFuture = CartApiService().getCart().then((cart) {
      setState(() {
        cartModel = cart;
        isChecked = List<bool>.filled(cart.chiTietGioHang.length, false);
      });
      return cart;
    });
  }

  Future<ProductModel> fetchProduct(String productID) async {
    return await ProductApiService().getProductByID(productID);
  }

  Future<void> updateItem(
      String idGioHang, String idBienThe, int soLuong, int donGia) async {
    // Update locally first
    setState(() {
      cartModel?.chiTietGioHang
          .firstWhere((item) => item.variantModel.id == idBienThe)
          .soLuong = soLuong;
    });

    // Then call API to update on server
    try {
      await CartApiService().updateCart(idGioHang, idBienThe, soLuong, donGia);
    } catch (e) {
      print("Failed to update: $e");
      // Revert changes if API update fails
      setState(() {
        cartModel?.chiTietGioHang
            .firstWhere((item) => item.variantModel.id == idBienThe)
            .soLuong = soLuong > 0 ? soLuong - 1 : 1;
      });
    }
  }

  Future<void> removeItem(String idGioHang, String idBienThe) async {
    try {
      await CartApiService().deleteFromCart(idGioHang, idBienThe);
      setState(() {
        cartModel?.chiTietGioHang
            .removeWhere((item) => item.variantModel.id == idBienThe);
      });
    } catch (e) {
      print("Failed to remove: $e");
    }
  }

  int calculateTotalPrice() {
    int total = 0;
    for (int i = 0; i < cartModel!.chiTietGioHang.length; i++) {
      if (isChecked[i]) {
        final item = cartModel!.chiTietGioHang[i];
        total += item.soLuong * item.donGia;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Giỏ hàng'),
      ),
      body: cartModel == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator while fetching the cart
          : cartModel!.chiTietGioHang.isEmpty
          ?Center(
                  child: Text(
                    'Giỏ hàng trống',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartModel!.chiTietGioHang.length,
                    itemBuilder: (context, index) {
                      final item = cartModel!.chiTietGioHang[index];

                      return FutureBuilder<ProductModel>(
                        future: fetchProduct(item.variantModel.idProduct),
                        builder: (context, productSnapshot) {
                          if (!productSnapshot.hasData) {
                            return  SizedBox.shrink();;
                          }

                          ProductModel product = productSnapshot.data!;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Checkbox(
                                        value: isChecked[index],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked[index] = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                product.imageProduct),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${product.nameProduct}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: item
                                                .variantModel.ketHopThuocTinh
                                                .map((thuocTinh) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Text(
                                                  '${thuocTinh.giaTriThuocTinh.GiaTri}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          SizedBox(height: 4),
                                          Text('Đơn giá: ${item.donGia} đ/kg'),
                                          SizedBox(height: 4),
                                          Container(
                                            width: double.infinity,
                                            height: 100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: IconButton(
                                                    iconSize: 20,
                                                    onPressed: () {
                                                      if (item.soLuong > 1) {
                                                        setState(() {
                                                          item.soLuong--;
                                                        });
                                                        updateItem(
                                                            cartModel!.id,
                                                            item.variantModel.id,
                                                            item.soLuong,
                                                            item.donGia);
                                                      }
                                                    },
                                                    icon: Icon(Icons.remove),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    "${item.soLuong}",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: IconButton(
                                                    iconSize: 20,
                                                    onPressed: () {
                                                      setState(() {
                                                        item.soLuong++;
                                                      });
                                                      updateItem(
                                                          cartModel!.id,
                                                          item.variantModel.id,
                                                          item.soLuong,
                                                          item.donGia);
                                                    },
                                                    icon: Icon(Icons.add),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          removeItem(cartModel!.id,
                                              item.variantModel.id);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Tổng tiền hàng:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${calculateTotalPrice()} đ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Colors.amber),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Thu thập các sản phẩm đã được chọn
                            List<ChiTietGioHang> selectedItems = [];
                            for (int i = 0;
                                i < cartModel!.chiTietGioHang.length;
                                i++) {
                              if (isChecked[i]) {
                                selectedItems.add(cartModel!.chiTietGioHang[i]);
                              }
                            }

                            if (selectedItems.isEmpty) {
                              // Hiển thị thông báo nếu không có sản phẩm nào được chọn
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Vui lòng chọn ít nhất một sản phẩm để mua.')),
                              );
                              return;
                            }

                            // Điều hướng đến PayScreen và truyền danh sách sản phẩm đã chọn
                            Navigator.pushNamed(
                              context,
                              '/pay_screen',
                              arguments: selectedItems,
                            );
                          },
                          child: Text("Mua ngay"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
