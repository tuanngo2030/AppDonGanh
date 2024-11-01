import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/khuyen_mai_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:don_ganh_app/screen/khuyen_mai_screen.dart';
import 'package:don_ganh_app/screen/pay_screen/exprire_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChoosePaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  const ChoosePaymentScreen({super.key, required this.orderModel});

  @override
  State<ChoosePaymentScreen> createState() => _ChoosePaymentScreenState();
}

class _ChoosePaymentScreenState extends State<ChoosePaymentScreen> {
  String? selectedPaymentMethod;
  final OrderApiService _orderApiService = OrderApiService();
  String selectedPromoCode = '';
  String selectedPromoId = '';
  int giaTriGiam = 0;

  Future<void> _updateTransaction(String hoadonId, String transactionId,
      String assetPath, String title, String? subtitle) async {
    try {
      final updatedOrder = await _orderApiService.updateTransactionHoaDon(
        hoadonId: hoadonId,
        transactionId: transactionId,
        khuyeimaiId: '',
        giaTriGiam: 0,
      );

      setState(() {
        selectedPaymentMethod = 'Qr';
      });

      

       final String paymentUrl = updatedOrder.payment_url ?? '';
      print('payment url: $paymentUrl');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExprireScreen(
            title: 'Thanh toán',
            orderModel: widget.orderModel,
            paymentUrl: paymentUrl,
          ),
        ),
      );
      _showSnackbar(context, 'QR payment updated successfully.');
    } catch (e) {
      print('Error updating transaction for QR: $e');
      _showSnackbar(
          context, 'An error occurred while updating the QR transaction.');
    }
  }

  Future<void> _updateTransactionCOD(String hoadonId, String transactionId,
      String assetPath, String title, String? subtitle) async {
    try {
      OrderModel? updatedOrder =
          await _orderApiService.updateTransactionHoaDonCOD(
        hoadonId: hoadonId,
        transactionId: transactionId,
        khuyeimaiId: '',
        giaTriGiam: 0,
      );

      setState(() {
        selectedPaymentMethod = 'COD';
      });
      _showSnackbar(context, 'COD payment updated successfully.');
    } catch (e) {
      print('Error updating transaction for COD: $e');
      _showSnackbar(
          context, 'An error occurred while updating the COD transaction.');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void updatePromoCode(KhuyenMaiModel promotion) {
    setState(() {
      selectedPromoId = promotion
          .id; // Assuming you want to store the promotion ID for later use
      selectedPromoCode = promotion.tenKhuyenMai;
      giaTriGiam = promotion.giaTriGiam;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chọn phương thức thanh toán'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildOrderDetailText('Mã đơn hàng: ', widget.orderModel.id),
                buildOrderDetailText('Người nhận hàng: ',
                    '${widget.orderModel.diaChi.name}, ${widget.orderModel.diaChi.soDienThoai}'),
                buildOrderDetailText('Địa chỉ nhận: ',
                    '${widget.orderModel.diaChi.duongThon}, ${widget.orderModel.diaChi.phuongXa}, ${widget.orderModel.diaChi.quanHuyen}, ${widget.orderModel.diaChi.tinhThanhPho}'),
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
      ),
    );
  }

  Widget buildOrderDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget buildPaymentMethod({
    required String assetPath,
    required String title,
    String? subtitle,
    required String value,
  }) {
    return GestureDetector(
      onTap: () async {
        // final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
       
        String transactionId = value == 'Qr' ? '151' : '111';

        if (value == 'Qr') {
          // await _updateTransaction(
          //     hoadonId, transactionId, assetPath, title, subtitle);
          setState(() {
            selectedPaymentMethod = value;
          });
        } else if (value == 'COD') {
          // await _updateTransactionCOD(
          //     hoadonId, transactionId, assetPath, title, subtitle);
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
                'Tổng giá trị thanh toán',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat
                    .format(widget.orderModel.TongTien), // Format total price
                style: const TextStyle(fontSize: 14),
              ),
              const Text(
                'Giá trị đơn hàng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat
                    .format(widget.orderModel.TongTien), // Format order value
                style: const TextStyle(fontSize: 14),
              ),
              const Text(
                'Phí dịch vụ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat
                    .format(widget.orderModel.TongTien), // Format service fee
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
              onPressed: () async {
                String hoadonId = widget.orderModel.id;
                String transactionId = '151';
                String transactionIdCod = '111';
                if (selectedPaymentMethod == 'Qr') {
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

                  await _updateTransaction(hoadonId, transactionId, assetPath,
                      paymentDetails, paymentSubtitle);
                } else if (selectedPaymentMethod == 'COD') {
                  // Nếu chọn COD, gọi API riêng
                  await _updateTransactionCOD(hoadonId, transactionIdCod,
                      assetPath, paymentDetails, paymentSubtitle);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tiếp tục'),
            ),
          ),
        )
      ],
    );
  }

  void _showPromotionBottomSheet() {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    int total = widget.orderModel.TongTien;
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
