import 'package:don_ganh_app/Profile_Screen/paymentmethods_screen.dart';
import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/khuyen_mai_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:don_ganh_app/screen/khuyen_mai_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PayScreen2 extends StatefulWidget {
  final VoidCallback nextStep;
  const PayScreen2({super.key, required this.nextStep});

  @override
  State<PayScreen2> createState() => _PayScreen2State();
}

class _PayScreen2State extends State<PayScreen2> {
  String? selectedPaymentMethod;
  String payment_url = '';
  final OrderApiService _orderApiService = OrderApiService();
  bool _isProcessing = false;
  String selectedPromoCode = '';
  String selectedPromoId = '';
  int giaTriGiam = 0;
  // late Future<Map<String, dynamic>> productData;

  void updatePromoCode(KhuyenMaiModel promotion) {
    setState(() {
      selectedPromoId = promotion
          .id; // Assuming you want to store the promotion ID for later use
      selectedPromoCode = promotion.tenKhuyenMai;
      giaTriGiam = promotion.giaTriGiam;
    });
  }

  Future<void> _updateTransaction(String hoadonId, String transactionId,
      String assetPath, String title, String? subtitle) async {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    setState(() {
      _isProcessing = true;
    });
    // Assuming you have the PaymentInfo instance as paymentInfo

// Access the _orders list using the getter
    List<OrderModel> orders = paymentInfo.orders;

    try {
      OrderModel? updatedOrder =
          await _orderApiService.updateTransactionHoaDonList(
        list: orders,
        hoadonId: hoadonId,
        transactionId: transactionId,
        khuyeimaiId: selectedPromoId,
        giaTriGiam: giaTriGiam,
      );

      print("Updated Order ID: ${updatedOrder.payment_url}");
      paymentInfo.paymentMehtod(
          assetPath: assetPath,
          title: title,
          subtitle: subtitle,
          // payment_url: updatedOrder.payment_url,
          giaTriGiam: giaTriGiam);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công! ID: ${updatedOrder.id}')),
      );

      widget.nextStep();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thành công!')),
      );
      paymentInfo.paymentMehtod(
          assetPath: assetPath,
          title: title,
          subtitle: subtitle,
          // payment_url: updatedOrder.payment_url,
          giaTriGiam: giaTriGiam);

      widget.nextStep();
      // Navigator.pushNamed(context, '/bottomnavigation');
      print('Error updating transaction: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Lỗi khi cập nhật giao dịch.')),
      // );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _updateTransactionCOD(String hoadonId, String transactionId,
      String assetPath, String title, String? subtitle) async {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    List<OrderModel> orders = paymentInfo.orders;
    setState(() {
      _isProcessing = true;
    });

    try {
      OrderModel? updatedOrder =
          await _orderApiService.updateTransactionHoaDonCODList(
        list: orders,
        hoadonId: hoadonId,
        transactionId: transactionId,
        khuyeimaiId: selectedPromoId,
        giaTriGiam: giaTriGiam,
      );

      print("Updated Order ID: ${updatedOrder.payment_url}");
      paymentInfo.paymentMehtod(
          assetPath: assetPath,
          title: title,
          subtitle: subtitle,
          // payment_url: updatedOrder.payment_url,
          giaTriGiam: giaTriGiam);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công! ID: ${updatedOrder.id}')),
      );

      widget.nextStep();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thành công!')),
      );
      paymentInfo.paymentMehtod(
          assetPath: assetPath,
          title: title,
          subtitle: subtitle,
          // payment_url: updatedOrder.payment_url,
          giaTriGiam: giaTriGiam);
      widget.nextStep();
      // Navigator.pushNamed(context, '/bottomnavigation');
      print('Error updating COD transaction: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Lỗi khi cập nhật giao dịch COD.')),
      // );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentInfo = Provider.of<PaymentInfo>(context);
    final orders = paymentInfo.orders; // Access the orders list

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Danh sách đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Orders List
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display order details
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Mã đơn hàng: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: order.id,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Display chiTietHoaDon details
                          if (order.chiTietHoaDon != null)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.chiTietHoaDon!.length,
                              itemBuilder: (context, chiTietIndex) {
                                final chiTiet =
                                    order.chiTietHoaDon![chiTietIndex];
                                Future<Map<String, dynamic>> productData =
                                    ProductApiService()
                                        .getVariantById(chiTiet.bienThe);

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   'Sản phẩm: ${chiTiet.bienThe}', // Tên biến thể
                                      //   style: const TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: productData,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            var product = snapshot.data;

                                            // Extract GiaTri from KetHopThuocTinh
                                            List<String> ketHopThuocTinhValues =
                                                [];
                                            for (var item in product?[
                                                    'KetHopThuocTinh'] ??
                                                []) {
                                              ketHopThuocTinhValues.add(
                                                  item['IDGiaTriThuocTinh']
                                                      ['GiaTri']);
                                            }

                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    product?['IDSanPham']
                                                            ['HinhSanPham'] ??
                                                        '',
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${product?['IDSanPham']['TenSanPham']}',
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      'Loại sản phẩm: ${ketHopThuocTinhValues.join(", ")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      'Số lượng: ${chiTiet.soLuong}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Đơn giá: ${NumberFormat("#,##0").format(chiTiet.donGia)} VND',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            );
                                          } else {
                                            return const Text(
                                                'No product found');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Payment Method Section
              const Padding(
                padding: EdgeInsets.only(top: 25, bottom: 20),
                child: Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // paymentInfo.assetPath.isEmpty
              buildPaymentMethodsList()
              // : buildSelectedMethodDetails(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget function to build Payment Methods List
  Widget buildPaymentMethodsList() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_money.png',
          title: 'Giao hàng thu tiền (COD)',
          subtitle: 'Thu bằng tiền mặt',
          value: 'COD',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_vietqr.png',
          title: 'VietQR',
          subtitle:
              'Ghi nhận giao dịch tức thì. QR được chấp nhận bởi 40+ Ngân hàng và ví điện tử ',
          value: 'VietQR',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/Baokim-logo.png',
          title: 'ATM Card',
          subtitle: 'Chuyển tiền nhanh chóng',
          value: 'Qr',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_vnpay.png',
          title: 'VNPAY QR',
          subtitle: 'Ghi nhận giao dịch tức thì',
          value: 'VNPAY',
        ),
      ],
    );
  }

  // Widget function for Payment Method ListTile
  Widget buildPaymentMethod({
    required String assetPath,
    required String title,
    String? subtitle,
    required String value,
  }) {
    return GestureDetector(
      onTap: () async {
        final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
        String hoadonId = paymentInfo.order_id;
        String transactionId = '151';
        String transactionIdCod = '111';
        String transactionIdVietQR = '295';
        String transactionIdVNPAY = '297';
        if (value == 'Qr') {
          print(selectedPromoId);
          await _updateTransaction(
            hoadonId,
            transactionId,
            assetPath,
            title,
            subtitle,
          );

          // setState(() {
          //   selectedPaymentMethod = value;
          // });
        } else if (value == 'COD') {
          await _updateTransactionCOD(
            hoadonId,
            transactionIdCod,
            assetPath,
            title,
            subtitle,
          );
        } else if (value == 'VietQR') {
          await _updateTransaction(
            hoadonId,
            transactionIdVietQR,
            assetPath,
            title,
            subtitle,
          );
        }else if (value == 'VNPAY') {
          await _updateTransaction(
            hoadonId,
            transactionIdVNPAY,
            assetPath,
            title,
            subtitle,
          );
        } else {
          setState(() {
            selectedPaymentMethod = value;
          });
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Image.asset(assetPath, width: 40, height: 40),
          title: Text(title),
          subtitle: subtitle != null
              ? Text(subtitle, style: const TextStyle(fontSize: 12))
              : null,
        ),
      ),
    );
  }

// Details of the selected payment method
  Widget buildSelectedMethodDetails() {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    String paymentDetails = '';
    String paymentTitle = '';
    String paymentSubtitle = '';
    String assetPath = '';

    switch (selectedPaymentMethod) {
      case 'COD':
        paymentDetails = 'Giao hàng thu tiền (COD)';
        paymentSubtitle = 'Thu bằng tiền mặt';
        assetPath = 'lib/assets/ic_money.png';
        break;
      case 'Qr':
        paymentDetails = 'Bảo Kim';
        paymentSubtitle = 'Chuyển tiền nhanh chóng';
        assetPath = 'lib/assets/Baokim-logo.png';
        break;
    }

    final NumberFormat currencyFormat =
        NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            leading: Image.asset(assetPath, width: 40, height: 40),
            title: Text(paymentDetails),
            subtitle: paymentSubtitle.isNotEmpty
                ? Text(paymentSubtitle, style: const TextStyle(fontSize: 12))
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: const Border.fromBorderSide(
                BorderSide(color: Color.fromARGB(179, 177, 174, 174)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Mã: $selectedPromoCode'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        _showPromotionBottomSheet(); // Show the dialog when pressed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Chọn mã'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giá trị đơn hàng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: currencyFormat.format(paymentInfo.totalPrice),
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                    const TextSpan(
                      text: ' - ', // Add separator between the two values
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                    TextSpan(
                      text: currencyFormat.format(giaTriGiam),
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors
                              .red), // Style the discount value differently
                    ),
                  ],
                ),
              ),
              const Text(
                'Giá trị khuyến mãi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(giaTriGiam), // Format order value
                style: const TextStyle(fontSize: 14),
              ),
              const Text(
                'Phí dịch vụ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat
                    .format(paymentInfo.totalPrice), // Format service fee
                style: const TextStyle(fontSize: 14),
              ),
              const Text(
                'Tổng giá trị thanh toán',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(
                    paymentInfo.totalPrice - giaTriGiam), // Format total price
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final paymentInfo =
                          Provider.of<PaymentInfo>(context, listen: false);
                      String hoadonId = paymentInfo.order_id;
                      String transactionId = '151';
                      String transactionIdCod = '111';

                      if (selectedPaymentMethod == 'Qr') {
                        print(selectedPromoId);
                        await _updateTransaction(
                          hoadonId,
                          transactionId,
                          assetPath,
                          paymentDetails,
                          paymentSubtitle,
                        );
                      } else if (selectedPaymentMethod == 'COD') {
                        await _updateTransactionCOD(
                          hoadonId,
                          transactionIdCod,
                          assetPath,
                          paymentDetails,
                          paymentSubtitle,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                foregroundColor: Colors.white,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Tiếp tục'),
            ),
          ),
        )
      ],
    );
  }

  void _showPromotionBottomSheet() {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    int total = paymentInfo.totalPrice.toInt();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take up more space
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *
              0.75, // Adjust height as needed
          child: KhuyenMaiScreen(
            totalAmount: total,
            onPromotionSelected: updatePromoCode,
          ), // Use the existing KhuyenMaiScreen
        );
      },
    );
  }
}
