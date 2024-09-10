import 'package:flutter/material.dart';

class PayScreen2 extends StatefulWidget {
  const PayScreen2({super.key});

  @override
  State<PayScreen2> createState() => _PayScreen2State();
}

class _PayScreen2State extends State<PayScreen2> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
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
                        text: 'Anh An Nguyen, 0707449425',
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
                            '18/27 Phạm Thế Hiển, P. Tân An, TP. Buôn Mê Thuột, Tỉnh Đắk Lắk',
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
          assetPath: 'lib/assets/ic_vietqr.png',
          title: 'Quét mã chuyển khoản VietQR',
          subtitle:
              'Ghi nhận giao dịch tức thì. QR được chấp nhận bởi 40+ Ngân hàng và ví điện tử',
          value: 'VietQR',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_bankcard.png',
          title: 'Thẻ ATM',
          value: 'ATM',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_bankcard.png',
          title: 'Thẻ Visa, MasterCard, JCB',
          value: 'CreditCard',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_money.png',
          title: 'Giao hàng thu tiền (COD)',
          value: 'COD',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_bank.png',
          title: 'Tài khoản ngân hàng',
          subtitle: 'Chấp nhận MB Bank, PVcom Bank',
          value: 'BankAccount',
        ),
        buildPaymentMethod(
          assetPath: 'lib/assets/ic_vnpay.png',
          title: 'VNPAY QR',
          value: 'VNPAYQR',
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
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
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
      case 'VietQR':
        paymentDetails = 'Quét mã chuyển khoản VietQR';
        paymentSubtitle =
            'Ghi nhận giao dịch tức thì. QR được chấp nhận bởi 40+ Ngân hàng và ví điện tử';
        assetPath = 'lib/assets/ic_vietqr.png';
        break;
      case 'ATM':
        paymentDetails = 'Thẻ ATM';
        assetPath = 'lib/assets/ic_bankcard.png';
        break;
      case 'CreditCard':
        paymentDetails = 'Thẻ Visa, MasterCard, JCB';
        assetPath = 'lib/assets/ic_bankcard.png';
        break;
      case 'COD':
        paymentDetails = 'Giao hàng thu tiền (COD)';
        assetPath = 'lib/assets/ic_money.png';
        break;
      case 'BankAccount':
        paymentDetails = 'Tài khoản ngân hàng';
        paymentSubtitle = 'Chấp nhận MB Bank, PVcom Bank';
        assetPath = 'lib/assets/ic_bank.png';
        break;
      case 'VNPAYQR':
        paymentDetails = 'VNPAY QR';
        assetPath = 'lib/assets/ic_vnpay.png';
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