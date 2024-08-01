import 'package:flutter/material.dart';

class BanLa extends StatelessWidget {
  const BanLa({super.key});
// thanh
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 87, 35),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // logo
              Image.asset("lib/assets/logo_xinchao.png"),
              const Text(
                'Đòn gánh xin chào!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Add space between the two texts
              const Text(
                'Ứng dụng giúp cuộc sống dễ dàng hơn, với những nông sản tươi ngon, Đòn gánh sẵn sàng phục vụ bạn mọi nơi.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40), // Add space between texts and buttons
              const Text(
                'Bạn là ?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
                SizedBox(height: 20),
            UserOption(
              text: 'Khách mua hàng',
              onTap: () {
                // Xử lý khi chọn "Khách mua hàng"
              },
            ),
            SizedBox(height: 20),
            UserOption(
              text: 'Hộ kinh doanh',
              onTap: () {
                // Xử lý khi chọn "Hộ kinh doanh"
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}






class UserOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const UserOption({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 122,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 41, 87, 35),
            ),
          ),
        ),
      ),
    );
  }
}