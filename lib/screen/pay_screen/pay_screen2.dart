import 'package:don_ganh_app/Profile_Screen/paymentmethods_screen.dart';
import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayScreen2 extends StatefulWidget {
  final VoidCallback nextStep;
  const PayScreen2({super.key, required this.nextStep});
   
  @override
  State<PayScreen2> createState() => _PayScreen2State();
}
 
class _PayScreen2State extends State<PayScreen2> {
  String? selectedPaymentMethod;
    final OrderApiService _orderApiService = OrderApiService();
    bool _isProcessing = false;

   Future<void> _updateTransaction(String _hoadonId, String _transactionId) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      OrderModel updatedOrder = await _orderApiService.updateTransactionHoaDon(
        hoadonId: _hoadonId,
        transactionId: _transactionId,
      );

      print("Updated Order ID: ${updatedOrder.id}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công! ID: ${updatedOrder.id}')),
      );
    } catch (e) {
      print('Error updating transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật giao dịch.')),
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mã đơn hàng: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: '7R704UU3',
                        style: TextStyle(
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
                      TextSpan(
                        text: 'Người nhận hàng: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: '${paymentInfo.hoTen},${paymentInfo.soDienThoai}',
                        style: TextStyle(
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
                      TextSpan(
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
                        style: TextStyle(
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
                padding: const EdgeInsets.only(top: 25, bottom: 20),
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

               // Nút Tiếp tục
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(59, 99, 53, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Tiếp tục',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget function to build Payment Methods List
  Widget buildPaymentMethodsList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_money.png',
          title: 'Giao hàng thu tiền (COD)',
          value: 'COD',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/Baokim-logo.png',
          title: 'Bảo Kim',
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
}) 

{
  return GestureDetector(
    onTap: () async {
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
        final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
        String hoadonId = paymentInfo.order_id;
        String transactionId = '151';

        await _updateTransaction(hoadonId, transactionId);
        
      } else {
        setState(() {
          selectedPaymentMethod = value;
        });
      }
    },
    child: Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(assetPath, width: 40, height: 40),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(fontSize: 12))
            : null,
      ),
    ),
  );
}


  // Details of the selected payment method
  Widget buildSelectedMethodDetails() {
    String paymentDetails = '';
    String paymentTitle = '';
    String paymentSubtitle = '';
    String assetPath = '';

    switch (selectedPaymentMethod) {
      case 'COD':
        paymentDetails = 'Giao hàng thu tiền (COD)';
        assetPath = 'lib/assets/ic_money.png';
        break;
      case 'Qr':
        paymentDetails = 'Bảo Kim';
        assetPath = 'lib/assets/Baokim-logo.png';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            leading: Image.asset(assetPath, width: 40, height: 40),
            title: Text(paymentDetails),
            subtitle: paymentSubtitle.isNotEmpty
                ? Text(paymentSubtitle, style: TextStyle(fontSize: 12))
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.fromBorderSide(
                      BorderSide(color: Color.fromARGB(179, 177, 174, 174)))),
              child: Row(
                children: [
                  Expanded(
                    flex: 7, 
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Mã'),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      flex: 3,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Chọn mã'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(59, 99, 53, 1),
                            foregroundColor: Colors.white,
                          )),
                    ),
                  ),
                ],
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tổng giá trị thanh toán',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '40.000 đ',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Giá trị đơn hàng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '40.000 đ',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Phí dịch vụ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '0 đ',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}