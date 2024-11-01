import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExprireScreen extends StatefulWidget {
  final OrderModel orderModel;
  final String paymentUrl;
  final String title;

  const ExprireScreen({
    super.key,
    required this.orderModel,
    required this.paymentUrl,
    required this.title,
  });

  @override
  State<ExprireScreen> createState() => _ExprireScreenState();
}

class _ExprireScreenState extends State<ExprireScreen> {
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
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    // Use widget.orderModel to access the order data
    return Scaffold(
      appBar: AppBar(title:  Text('${widget.title} đơn hàng')),
      body: Column(
        children: [
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
                          '${widget.orderModel.TongTien} đ',
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
                          '${widget.orderModel.TongTien} đ',
                          style: const TextStyle(fontSize: 14),
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
                border: const Border.fromBorderSide(
                  BorderSide(color: Color.fromARGB(255, 174, 172, 172)),
                ),
              ),
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
        ],
      ),
    );
  }
}
