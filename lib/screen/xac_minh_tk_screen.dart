import 'package:don_ganh_app/screen/cach_xac_minh_tkScreen.dart';
import 'package:flutter/material.dart';

class XacMinhTkScreen extends StatefulWidget {
  final String email;
  const XacMinhTkScreen({super.key, required this.email});

  @override
  _XacMinhTkScreen createState() => _XacMinhTkScreen();
}

class _XacMinhTkScreen extends State<XacMinhTkScreen> {
  bool isSubscribed = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set giá trị email đã được truyền vào từ màn hình trước
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: const Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: const Text(
          'Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(41, 87, 35, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  icon: Image.asset(
                    'lib/assets/icongmail.png',
                    width: 30,
                    height: 30,
                    color: const Color.fromRGBO(41, 87, 35, 1),
                  ),
                  hintText: 'Nhập email của bạn',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CachXacMinhTkscreen(
                        email: _emailController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Tiếp theo',
                  style: TextStyle(fontSize: 18, color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: isSubscribed,
                    onChanged: (value) {
                      setState(() {
                        isSubscribed = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Gửi tôi thông tin sản phẩm mới, sản phẩm hot, chương trình khuyến mãi và cập nhật mới nhất của Đòn Gánh',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
