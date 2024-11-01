import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool isOrderExpired = false;

  late final WebViewController _webViewController;

  @override
  void initState() {
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
      );

    _checkOrderStatus();
  }

  Future<void> _checkOrderStatus() async {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);

    // Chỉ kiểm tra trạng thái đơn hàng nếu phương thức thanh toán là QR
    if (paymentInfo.title == 'Bảo Kim') {
      try {
        final data = await OrderApiService()
            .checkDonHangBaoKim(orderId: paymentInfo.order_id);
        setState(() {
          isOrderExpired = data['isExpired'] ?? false;
        });

        if (!isOrderExpired) {
          _webViewController.loadRequest(Uri.parse(paymentInfo.payment_url));
        }
      } catch (e) {
        print('Lỗi khi kiểm tra đơn hàng: $e');
        setState(() {
          isOrderExpired = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);

    return Scaffold(
      body: isOrderExpired
          ? _buildExpiredMessage()
          : isPaymentSuccessful
              ? _buildSuccessScreen()
              : _buildPaymentScreen(paymentInfo),
    );
  }

  Widget _buildSuccessScreen() {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Image.asset('lib/assets/img_success.png'),
          const SizedBox(height: 20),
          const Text(
            'Thanh toán thành công!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color.fromARGB(255, 174, 172, 172))),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thời gian giao dịch:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Mã đơn hàng:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mã đơn hàng:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          paymentInfo.order_id,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số tiền:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${paymentInfo.totalPrice}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hình thức giao dịch:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          paymentInfo.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          

          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bottomnavigation');
                Provider.of<PaymentInfo>(context, listen: false).reset();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                  foregroundColor: Colors.white),
              child: const Text('Trở về'))
        ],
      ),
    );
  }

  Widget _buildExpiredMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Đơn hàng đã hết hạn!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Trở về'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentScreen(PaymentInfo paymentInfo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading:
                  Image.asset(paymentInfo.assetPath, width: 40, height: 40),
              title: Text(paymentInfo.title),
              subtitle: paymentInfo.subtitle == ''
                  ? const Text('')
                  : Text('${paymentInfo.subtitle}',
                      style: const TextStyle(fontSize: 12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: const Border.fromBorderSide(
                  BorderSide(color: Color.fromARGB(255, 174, 172, 172)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng giá trị thanh toán:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${paymentInfo.totalPrice} đ',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Giá trị đơn hàng:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${paymentInfo.totalPrice} đ',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Ẩn WebView nếu là COD
          if (paymentInfo.title != 'Giao hàng thu tiền (COD)')
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: const Border.fromBorderSide(
                    BorderSide(color: Color.fromARGB(255, 174, 172, 172)),
                  ),
                ),
                child: WebViewWidget(controller: _webViewController),
              ),
            ),

          // Spacer để đẩy button xuống dưới
          const Spacer(),

          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  //  paymentInfo.title == 'Giao hàng thu tiền (COD)' ?{ _buildSuccessScreen(),
                  //   // Provider.of<PaymentInfo>(context, listen: false).reset()
                  //   }
                  //   : _buildSuccessScreen();

                  if (paymentInfo.title == 'Giao hàng thu tiền (COD)') {
                    setState(() {
                      isPaymentSuccessful = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  paymentInfo.title == 'Giao hàng thu tiền (COD)'
                      ? 'Hoàn tất'
                      : 'Thanh toán',
                  style: const TextStyle(
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
