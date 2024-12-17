import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartModel>> _cartData;
  Set<String> selectedUsers = {}; // Lưu các user đã được chọn
  List<ChiTietGioHang> selectedVariants = [];
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _cartData = _fetchCart();
  }

  Future<List<CartModel>> _fetchCart() async {
    try {
      CartApiService cartApiService = CartApiService();
      return await cartApiService.getGioHangByUserId();
    } catch (e) {
      print("Error fetching cart: $e");
      return [];
    }
  }

  Future<void> removeItem(String gioHangId, String variantId) async {
    try {
      // Call the API to delete the product from the cart
      await CartApiService().deleteFromCart(gioHangId, variantId);

      // Get the current cart data
      final cartData = await _cartData;

      double removedItemPrice =
          0; // Variable to store the price of the removed item

      // Update the cart data by removing the item
      for (var cart in cartData) {
        for (var sanPhamCart in cart.mergedCart) {
          for (var sanPhamList in sanPhamCart.sanPhamList) {
            sanPhamList.chiTietGioHangs.removeWhere((chiTiet) {
              // If the chiTiet matches the variantId, calculate the price to remove
              if (chiTiet.variantModel.id == variantId) {
                removedItemPrice = chiTiet.variantModel.gia.toDouble() *
                    chiTiet.soLuong; // Calculate the price of the removed item
              }
              return chiTiet.variantModel.id == variantId;
            });
          }
          // Remove the product from the list if no chiTietGioHangs remain
          sanPhamCart.sanPhamList
              .removeWhere((sanPham) => sanPham.chiTietGioHangs.isEmpty);
        }
        // Remove empty mergedCart entries
        cart.mergedCart.removeWhere((merged) => merged.sanPhamList.isEmpty);
      }

      // Filter out empty CartModels
      final updatedCartData =
          cartData.where((cart) => cart.mergedCart.isNotEmpty).toList();

      // Update the total price by subtracting the removed item's price
      setState(() {
        _cartData = Future.value(updatedCartData); // Update the cart data
        totalPrice -=
            removedItemPrice; // Subtract the price of the removed item
      });
    } catch (e) {
      print("Failed to remove item: $e");
    }
  }

  Future<void> updateItem(String idGioHang, String idBienThe, int soLuong,
      int donGia, String idChitietgiohang) async {
    try {
      // Wait for the cart data to be fetched
      final cartData = await _cartData;

      setState(() {
        // Flatten the mergedCart and find the matching ChiTietGioHang
        final item = cartData
            .expand((cartModel) =>
                cartModel.mergedCart) // Flatten the mergedCart list
            .expand((sanPhamCart) =>
                sanPhamCart.sanPhamList) // Flatten the sanPhamList
            .expand((sanPhamList) =>
                sanPhamList.chiTietGioHangs) // Flatten chiTietGioHangs
            .firstWhere((item) => item.variantModel.id == idBienThe);

        item.soLuong = soLuong;

        // Cập nhật lại totalPrice sau khi thay đổi số lượng
        totalPrice = 0;
        for (var cartModel in cartData) {
          for (var sanPhamCart in cartModel.mergedCart) {
            for (var sanPhamItem in sanPhamCart.sanPhamList) {
              for (var chiTiet in sanPhamItem.chiTietGioHangs) {
                if (selectedVariants.contains(chiTiet)) {
                  totalPrice += chiTiet.donGia * chiTiet.soLuong;
                }
              }
            }
          }
        }
      });

      // Call the API to update on the server
      await CartApiService()
          .updateCart(idGioHang, idBienThe, soLuong, donGia, idChitietgiohang);
    } catch (e) {
      print("Failed to update: $e");

      // Revert changes if the API update fails
      final cartData = await _cartData; // Wait for the data to be fetched
      setState(() {
        final item = cartData
            .expand((cartModel) =>
                cartModel.mergedCart) // Flatten the mergedCart list
            .expand((sanPhamCart) =>
                sanPhamCart.sanPhamList) // Flatten the sanPhamList
            .expand((sanPhamList) =>
                sanPhamList.chiTietGioHangs) // Flatten chiTietGioHangs
            .firstWhere((item) => item.variantModel.id == idBienThe);

        item.soLuong =
            soLuong > 0 ? soLuong - 1 : 1; // Prevent negative quantity
      });
    }
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
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
              Navigator.pop(context);
            },
            child: Container(
              child: const ImageIcon(
                AssetImage('lib/assets/arrow_back.png'),
                size: 49,
              ),
            ),
          ),
        ),
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<CartModel>>(
        future: _cartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator only if data is not ready
            return const Center(
                child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color.fromRGBO(41, 87, 35, 1)),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống.'));
          }

          List<CartModel> cartList = snapshot.data!;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: cartList.length,
                itemBuilder: (context, index) {
                  var cart = cartList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cart.mergedCart.map((sanPhamCart) {
                      double groupTotal = 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            color: Colors.grey[200],
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Checkbox(
                                  value: selectedUsers
                                      .contains(sanPhamCart.user.id),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        // Select all products for this user
                                        selectedUsers.add(sanPhamCart.user.id!);
                                        for (var sanPhamItem
                                            in sanPhamCart.sanPhamList) {
                                          for (var chiTiet
                                              in sanPhamItem.chiTietGioHangs) {
                                            if (!selectedVariants
                                                .contains(chiTiet)) {
                                              selectedVariants.add(chiTiet);
                                              totalPrice += chiTiet.donGia *
                                                  chiTiet.soLuong;
                                            }
                                          }
                                        }
                                      } else {
                                        // Deselect all products for this user
                                        selectedUsers
                                            .remove(sanPhamCart.user.id);
                                        for (var sanPhamItem
                                            in sanPhamCart.sanPhamList) {
                                          for (var chiTiet
                                              in sanPhamItem.chiTietGioHangs) {
                                            if (selectedVariants
                                                .contains(chiTiet)) {
                                              selectedVariants.remove(chiTiet);
                                              totalPrice -= chiTiet.donGia *
                                                  chiTiet.soLuong;
                                            }
                                          }
                                        }
                                      }
                                    });
                                  },
                                  activeColor:
                                      const Color.fromRGBO(41, 87, 35, 1),
                                  visualDensity:
                                      const VisualDensity(horizontal: -4.0),
                                ),
                                Text(
                                  sanPhamCart.user.tenNguoiDung!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...sanPhamCart.sanPhamList.map((sanPhamItem) {
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Column(
                                children:
                                    sanPhamItem.chiTietGioHangs.map((chiTiet) {
                                  groupTotal +=
                                      chiTiet.donGia * chiTiet.soLuong;

                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: selectedVariants
                                              .contains(chiTiet),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedVariants.add(chiTiet);
                                                totalPrice += chiTiet.donGia *
                                                    chiTiet.soLuong;
                                              } else {
                                                selectedVariants
                                                    .remove(chiTiet);
                                                totalPrice -= chiTiet.donGia *
                                                    chiTiet.soLuong;
                                              }
                                            });
                                          },
                                          activeColor: const Color.fromRGBO(
                                              41, 87, 35, 1),
                                          visualDensity: const VisualDensity(
                                              horizontal: -4.0),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            sanPhamItem.sanPham.imageProduct ??
                                                '',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Loại: ${chiTiet.variantModel.ketHopThuocTinh.map((thuocTinh) => thuocTinh.giaTriThuocTinh.GiaTri).join(', ')}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  'Đơn giá: ${formatCurrency(chiTiet.donGia.toDouble())}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      IconButton(
                                                        iconSize: 20,
                                                        onPressed: () {
                                                          if (chiTiet.soLuong >
                                                              1) {
                                                            setState(() {
                                                              chiTiet.soLuong--;
                                                            });
                                                            updateItem(
                                                                cart.id,
                                                                chiTiet
                                                                    .variantModel
                                                                    .id,
                                                                chiTiet.soLuong,
                                                                chiTiet.donGia,
                                                                chiTiet.id);
                                                          }
                                                        },
                                                        icon: const Icon(
                                                            Icons.remove),
                                                      ),
                                                      Text(
                                                        "${chiTiet.soLuong}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      IconButton(
                                                        iconSize: 20,
                                                        onPressed: () {
                                                          if (chiTiet.soLuong <
                                                              10) {
                                                            setState(() {
                                                              chiTiet.soLuong++;
                                                            });
                                                            updateItem(
                                                                cart.id,
                                                                chiTiet
                                                                    .variantModel
                                                                    .id,
                                                                chiTiet.soLuong,
                                                                chiTiet.donGia,
                                                                chiTiet.id);
                                                          }
                                                        },
                                                        icon: const Icon(
                                                            Icons.add),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Xác nhận xóa'),
                                                  content: const Text(
                                                      'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child:
                                                          const Text('Không'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text('Có'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close dialog
                                                        removeItem(
                                                            cart.id,
                                                            chiTiet.variantModel
                                                                .id); // Perform delete
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }),
                          const Divider(),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng tiền hàng:',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatCurrency(totalPrice),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: selectedVariants.isNotEmpty
                            ? () {
                                // Filter mergedCart for selected items
                                final selectedCart = cartList
                                    .map((cart) {
                                      final filteredMergedCart = cart.mergedCart
                                          .map((sanPhamCart) {
                                            final filteredSanPhamList =
                                                sanPhamCart.sanPhamList
                                                    .map((sanPhamItem) {
                                                      final filteredChiTiet =
                                                          sanPhamItem
                                                              .chiTietGioHangs
                                                              .where((chiTiet) =>
                                                                  selectedVariants
                                                                      .contains(
                                                                          chiTiet))
                                                              .toList();
                                                      return filteredChiTiet
                                                              .isNotEmpty
                                                          ? SanPhamList(
                                                              user: sanPhamItem
                                                                  .user,
                                                              sanPham:
                                                                  sanPhamItem
                                                                      .sanPham,
                                                              chiTietGioHangs:
                                                                  filteredChiTiet)
                                                          : null;
                                                    })
                                                    .whereType<SanPhamList>()
                                                    .toList();
                                            return filteredSanPhamList
                                                    .isNotEmpty
                                                ? SanPhamCart(
                                                    user: sanPhamCart.user,
                                                    sanPhamList:
                                                        filteredSanPhamList)
                                                : null;
                                          })
                                          .whereType<SanPhamCart>()
                                          .toList();
                                      return filteredMergedCart.isNotEmpty
                                          ? CartModel(
                                              id: cart.id,
                                              user: cart.user,
                                              mergedCart: filteredMergedCart)
                                          : null;
                                    })
                                    .whereType<CartModel>()
                                    .toList();

                                Navigator.pushNamed(
                                  context,
                                  '/pay_screen',
                                  arguments: selectedCart,
                                );
                              }
                            : null,
                        child: const Text('Mua ngay'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
