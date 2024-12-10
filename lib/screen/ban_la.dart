import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BanLa extends StatelessWidget {
  const BanLa({super.key});

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role'); // Lấy role từ SharedPreferences
  }

  Future<void> _setChooseRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chooseRole', role); // Lưu vai trò vào SharedPreferences
  }

  void _navigateToBusiness(BuildContext context) async {
    final role = await _getUserRole();

    if (role != 'hokinhdoanh') {
      // Nếu không phải là hộ kinh doanh, hiển thị SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng ký Hộ kinh doanh ở trang cá nhân.'),
        ),
      );
    } else {
      // Lưu vai trò và chuyển hướng
      await _setChooseRole('hokinhdoanh');
      Navigator.pushNamed(context, "/bottomThumua");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 87, 35),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 16.0, right: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
                  'Ứng dụng giúp cuộc sống dễ dàng hơn, với những nông sản tươi ngon, Đòn gánh sẵn sàng phục vụ bạn mọi nơi.',
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
                const SizedBox(height: 20),
                UserOption(
                  text: 'Khách mua hàng',
                  onTap: () async {
                    // Lưu vai trò và chuyển hướng
                    await _setChooseRole('khachmuahang');
                    Navigator.pushNamed(context, "/bottom");
                  },
                ),
                const SizedBox(height: 20),
                UserOption(
                  text: 'Hộ kinh doanh',
                  onTap: () => _navigateToBusiness(context), // Gọi hàm kiểm tra vai trò
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class UserOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const UserOption({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 122,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 41, 87, 35),
            ),
          ),
        ),
      ),
    );
  }
}
