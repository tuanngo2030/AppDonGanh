import 'package:don_ganh_app/Profile_Screen/paymentmethods_screen.dart';
import 'package:don_ganh_app/api_services/order_api_service.dart';
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
      OrderModel? updatedOrder = await _orderApiService.updateTransactionHoaDonList(
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
          payment_url: updatedOrder.payment_url,
          giaTriGiam: giaTriGiam
        );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công! ID: ${updatedOrder.id}')),
      );

      widget.nextStep();
    } catch (e) {
      print('Error updating transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật giao dịch.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _updateTransactionCOD(String hoadonId, String transactionId,
      String assetPath, String title, String? subtitle) async {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    setState(() {
      _isProcessing = true;
    });

    try {
      OrderModel? updatedOrder =
          await _orderApiService.updateTransactionHoaDonCOD(
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
          payment_url: updatedOrder.payment_url,
          giaTriGiam: giaTriGiam
        );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công! ID: ${updatedOrder.id}')),
      );

      widget.nextStep();
    } catch (e) {
      print('Error updating COD transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật giao dịch COD.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentInfo = Provider.of<PaymentInfo>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
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
                        text: paymentInfo.order_id,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Người nhận hàng: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: '${paymentInfo.hoTen},${paymentInfo.soDienThoai}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Địa chỉ nhận: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${paymentInfo.duongThonXom}, ${paymentInfo.phuongXa}, ${paymentInfo.quanHuyen}, ${paymentInfo.tinhThanhPho}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              selectedPaymentMethod == null
                  ? buildPaymentMethodsList()
                  : buildSelectedMethodDetails(),

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
          assetPath: 'lib/assets/Baokim-logo.png',
          title: 'Bảo Kim',
          subtitle: 'Chuyển tiền nhanh chóng',
          value: 'Qr',
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
        if (value == 'Qr') {
          // Điều hướng sang PaymentMethodsScreen khi chọn "Tài khoản ngân hàng"
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => PaymentMethodsScreen(),
          //   ),
          // ).then((selectedId) {
          //   if (selectedId != null) {
          //     setState(() {
          //       this.selectedPaymentMethod = selectedId.toString(); // Lưu ID đã chọn
          //     });
          //   }
          // });
          // final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
          // String hoadonId = paymentInfo.order_id;
          // String transactionId = '151';

          // await _updateTransaction(hoadonId, transactionId, assetPath, title, subtitle);
          setState(() {
            selectedPaymentMethod = value;
          });
        } else if (value == 'COD') {
          // Nếu chọn COD, gọi API riêng
          // await _updateTransactionCOD(hoadonId, transactionIdCod, assetPath, title, subtitle);
          setState(() {
            selectedPaymentMethod = value;
          });
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
                      style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                    const TextSpan(
                      text: ' - ', // Add separator between the two values
                      style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
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
