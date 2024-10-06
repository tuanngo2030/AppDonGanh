import 'package:flutter/material.dart';

class PayScreen3 extends StatefulWidget {
  const PayScreen3({super.key});

  @override
  State<PayScreen3> createState() => _PayScreen3State();
}
 
class _PayScreen3State extends State<PayScreen3> {
  String paymentSubtitle = "";
  bool isPaymentSuccessful = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPaymentSuccessful ? _buildSuccessScreen() : _buildPaymentScreen(),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        children: [
          Image.asset('lib/assets/img_success.png'),
          SizedBox(height: 20),
          Text(
            'Thanh toán thành công!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.fromBorderSide(
                    BorderSide(color: Color.fromARGB(255, 174, 172, 172))),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thời gian giao dịch:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' 2023-10-16 03:33:38',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mã đơn hàng:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '7R7O4UU3',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số tiền:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '40.000 đ',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hình thức thanh toán : ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'COD',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Quý khách có thể tra cứu trạng thái đơn hàng'),
              TextButton(
                  onPressed: () {},
                  child: Text('Tại đây',
                      style: TextStyle(
                          color: Color.fromRGBO(248, 158, 25, 1),
                          decoration: TextDecoration.underline)))
            ],
          ),
          ElevatedButton(
              onPressed: () {},
              child: Text('Trở về'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(59, 99, 53, 1),
                foregroundColor: Colors.white
               
              )
            )
        ],
      ),
    );
  }

  Widget _buildPaymentScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Image.asset('lib/assets/ic_money.png',
                    width: 40, height: 40),
                title: Text('Giao hàng thu tiền (COD)'),
                subtitle: paymentSubtitle.isNotEmpty
                    ? Text(paymentSubtitle, style: TextStyle(fontSize: 12))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.fromBorderSide(
                      BorderSide(color: Color.fromARGB(255, 174, 172, 172))),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng giá trị thanh toán:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '40.000 đ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Giá trị đơn hàng:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '40.000 đ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phí dịch vụ:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '40.000 đ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Khuyến mãi:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '40.000 đ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isPaymentSuccessful = true;
                });
              },
              child: Text('test'),
            ),
          ],
        ),
      ),
    );
  }
}
