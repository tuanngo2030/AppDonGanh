import 'package:flutter/material.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen1.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen2.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen3.dart';

class PayProcessScreen extends StatefulWidget {
  @override
  _PayProcessScreenState createState() => _PayProcessScreenState();
}

class _PayProcessScreenState extends State<PayProcessScreen> {
  PageController _pageController = PageController(initialPage: 0);
  int currentStep = 0;

  // Hàm để chuyển qua bước tiếp theo
  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
        _pageController.animateToPage(
          currentStep,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  // Hàm để cập nhật màu sắc dựa trên bước hiện tại
  Color _getColor(int step) {
    return (step <= currentStep) ? Color.fromRGBO(59, 99, 53, 1) : Colors.grey;
  }

  // Hàm để cập nhật độ dày của đường kết nối
  double _getLineThickness(int step) {
    return (step <= currentStep) ? 5.0 : 2.0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thanh toán'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Step 1: Điền thông tin
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getColor(0),
                          border: Border.all(color: _getColor(0), width: 3),
                        ),
                        child: Icon(
                          Icons.assignment_ind,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Điền thông tin'),
                    ],
                  ),
                  // Đường kẻ
                  Expanded(
                    child: Container(
                      height: _getLineThickness(1),
                      color: _getColor(1),
                    ),
                  ),
                  // Step 2: Phương thức thanh toán
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getColor(1),
                          border: Border.all(color: _getColor(1), width: 3),
                        ),
                        child: Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Phương thức\nthanh toán',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  // Đường kẻ
                  Expanded(
                    child: Container(
                      height: _getLineThickness(2),
                      color: _getColor(2),
                    ),
                  ),
                  // Step 3: Thanh toán
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getColor(2),
                          border: Border.all(color: _getColor(2), width: 3),
                        ),
                        child: Icon(
                          Icons.money,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Thanh toán'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  PayScreen1(),
                  PayScreen2(),
                  PayScreen3(),
                ],
              ),
            ),
            // Nút Tiếp tục
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextStep,
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
    );
  }
}
