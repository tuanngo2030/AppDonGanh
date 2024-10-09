import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayScreen3 extends StatefulWidget {
  final VoidCallback nextStep;
  const PayScreen3({super.key, required this.nextStep});

  @override
  State<PayScreen3> createState() => _PayScreen3State();
}
 
class _PayScreen3State extends State<PayScreen3> {
  String paymentSubtitle = "";
  bool isPaymentSuccessful = false;

  late final WebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
       ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Error loading page: ${error.errorCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://baokim.vn/?id=181016&mrc_order_id=tuanngo-20241008155248&stat=d&checksum=c2343556762779cf21840ef525d276b07852d1e967b17a557ed332f8795121d3')); // Thay thế bằng URL bạn muốn hiển thị
  }

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
    return Padding(
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.fromBorderSide(
                    BorderSide(color: Color.fromARGB(255, 174, 172, 172))),
              ),
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
    
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
                    'Thanh toán',
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
    );
  }
}
