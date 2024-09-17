import 'package:flutter/material.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  int _selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                child: ImageIcon(
                  AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
                  size: 49, // Kích thước hình ảnh
                ),
              ),
            ),
          ),
          title: Text('Đánh giá đơn hàng'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bạn cảm thấy đơn hàng thế nào?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Divider(thickness: 1),
                SizedBox(height: 8),
                Text(
                  'Đánh giá tổng thể',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                // Hiển thị các sao có thể chọn
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: _selectedStars > index
                            ? Colors.amber
                            : Color.fromARGB(255, 221, 220, 220),
                        size: 35,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedStars = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 8),
                Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Đánh giá chi tiết cảm nhận của bạn',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      TextField(
                        maxLines: 6,
                        minLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: 'Gõ vào đây',
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt_outlined),
                            Text('Thêm hình ảnh')
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(13),
                                child: Text(
                                  'Bỏ qua',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(59, 99, 53, 1),
                                  foregroundColor: Colors.white),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                print('$_selectedStars');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(13),
                                child: Text(
                                  'Xác nhận',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(59, 99, 53, 1),
                                  foregroundColor: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
