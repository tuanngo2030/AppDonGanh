import 'package:flutter/material.dart';

class CardLinkScreen extends StatelessWidget {
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
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          'Liên kết thẻ',
          style: TextStyle(
            color: Color.fromRGBO(41, 87, 35, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thẻ tín dụng/ghi nợ',
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
            ),
            SizedBox(height: 8),
            CardItem(
              imagePath: 'lib/assets/the_ngan_hang.png', // Thay đường dẫn đến hình ảnh của bạn
              label: '+ Thêm thẻ mới',
            ),
            SizedBox(height: 32),
            Text(
              'Tài khoản ngân hàng',
           style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
            ),
            SizedBox(height: 8),
            CardItem(
              imagePath: 'lib/assets/the_ngan_hang.png', // Thay đường dẫn đến hình ảnh của bạn
              label: '+ Thêm thẻ mới',
              
            ),
          ],
        ),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String imagePath;
  final String label;

  const CardItem({required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 2,
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 40, // Kích thước hình ảnh
          height: 40, // Kích thước hình ảnh
        ),
        title: Text(
          label,
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
        ),
        onTap: () {
          print("thêm thẻ");
        },
      ),
    );
  }
}
