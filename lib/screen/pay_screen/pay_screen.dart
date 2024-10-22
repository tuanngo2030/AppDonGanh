import 'package:don_ganh_app/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen1.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen2.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen3.dart';

class PayProcessScreen extends StatefulWidget {
  const PayProcessScreen({super.key});

  @override
  _PayProcessScreenState createState() => _PayProcessScreenState();
}

class _PayProcessScreenState extends State<PayProcessScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentStep = 0;

  // Hàm để chuyển qua bước tiếp theo
  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
        _pageController.animateToPage(
          currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  // Hàm để điều hướng đến bước khi nhấn vào biểu tượng
  void _goToStep(int step) {
    setState(() {
      currentStep = step;
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Hàm để cập nhật màu sắc dựa trên bước hiện tại
  Color _getColor(int step) {
    return (step <= currentStep) ? const Color.fromRGBO(59, 99, 53, 1) : Colors.white;
  }

  // Hàm để cập nhật độ dày của đường kết nối
  Color _getColorStick(int step) {
    return (step <= currentStep) ? const Color.fromRGBO(59, 99, 53, 1) : Colors.grey;
  }

  Color _getColorIcon(int step) {
    return (step <= currentStep) ? Colors.white : const Color.fromRGBO(59, 99, 53, 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<ChiTietGioHang> selectedItems = ModalRoute.of(context)!.settings.arguments as List<ChiTietGioHang>;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _goToStep(0);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(0),
                        border: Border.all(color: _getColor(0), width: 1),
                      ),
                      child: Icon(
                        Icons.assignment_ind,
                        color: _getColorIcon(0),
                        size: 24,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getColorStick(1),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (currentStep >= 1) _goToStep(1); // Chỉ cho phép quay lại nếu đã đến bước 1
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(1),
                        border: Border.all(color: _getColor(0), width: 1),
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: _getColorIcon(1),
                        size: 24,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getColorStick(2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (currentStep >= 2) _goToStep(2); // Chỉ cho phép quay lại nếu đã đến bước 2
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(2),
                        border: Border.all(color: _getColor(0), width: 1),
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                        color: _getColorIcon(2),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Điền thông tin", textAlign: TextAlign.start),
                  SizedBox(width: 45),
                  Text("Phương thức\nthanh toán", textAlign: TextAlign.center),
                  SizedBox(width: 45),
                  Text("Thanh toán"),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    PayScreen1(nextStep: _nextStep),
                    PayScreen2(nextStep: _nextStep),
                    PayScreen3(nextStep: _nextStep),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
