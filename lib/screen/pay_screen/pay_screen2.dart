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
    String payment_url = '';
    final OrderApiService _orderApiService = OrderApiService();
    bool _isProcessing = false;

   Future<void> _updateTransaction(String hoadonId, String transactionId, String assetPath, String title, String? subtitle) async {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    setState(() {
      _isProcessing = true;
    });

    try {
      OrderModel? updatedOrder = await _orderApiService.updateTransactionHoaDon(
        hoadonId: hoadonId,
        transactionId: transactionId,
      );

      print("Updated Order ID: ${updatedOrder.payment_url}");
       paymentInfo.paymentMehtod(
          assetPath: assetPath, 
          title: title, 
          subtitle: subtitle,
          payment_url: updatedOrder.payment_url
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


Future<void> _updateTransactionCOD(String hoadonId, String transactionId, String assetPath, String title, String? subtitle) async {
  final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
  setState(() {
    _isProcessing = true;
  });

  try {
    OrderModel? updatedOrder = await _orderApiService.updateTransactionHoaDonCOD(
      hoadonId: hoadonId,
      transactionId: transactionId,
    );

    print("Updated Order ID: ${updatedOrder.payment_url}");
    paymentInfo.paymentMehtod(
      assetPath: assetPath, 
      title: title, 
      subtitle: subtitle,
      payment_url: updatedOrder.payment_url
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
                  text:  TextSpan(
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

               // Nút Tiếp tục
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: 50,
            //     child: ElevatedButton(
            //       onPressed: widget.nextStep,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       child: const Text(
            //         'Tiếp tục',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
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
}) 

{
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

        await _updateTransaction(hoadonId, transactionId, assetPath, title, subtitle);
       
        
      }else if (value == 'COD') {
        // Nếu chọn COD, gọi API riêng
        await _updateTransactionCOD(hoadonId, transactionIdCod, assetPath, title, subtitle);
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
                      BorderSide(color: Color.fromARGB(179, 177, 174, 174)))),
              child: Row(
                children: [
                  const Expanded(
                    flex: 7, 
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Mã'),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      flex: 3,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Chọn mã')),
                    ),
                  ),
                ],
              )),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
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