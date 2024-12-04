import 'dart:io';

import 'package:don_ganh_app/api_services/review_api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderReviewScreen extends StatefulWidget {
  final String title;
  final String id;
  const OrderReviewScreen({super.key, required this.title, required this.id});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final ImagePicker _picker = ImagePicker();
  int _selectedStars = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<File> _imageFiles = []; // Changed to a list for multiple images
  String? userId;
  bool _isLoading = false; // Add loading state
  final bool _isSendReview = false;

  Future<void> _pickImage() async {
    final pickedFiles =
        await _picker.pickMultiImage(); // Sử dụng pickMultiImage

    setState(() {
      _imageFiles.addAll(pickedFiles.map((pickedFile) =>
          File(pickedFile.path))); // Thêm tất cả hình ảnh vào danh sách
    });
  }

  Future<void> _submitReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    setState(() {
      _isLoading = true; // Start loading
    });

    // if(_selectedStars < 1){
    //   setState(() {
    //     _isSendReview == false;
    //   });
    // }else{
    //    _isSendReview == true;
    // }

    try {
      // Call API to create review
      await ReviewApiService().createReview(
        userId: userId!,
        sanphamId: widget.id,
        xepHang: _selectedStars,
        binhLuan: _reviewController.text,
        imageFiles: _imageFiles, // Send the list of images
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đánh giá của bạn đã được gửi!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi gửi đánh giá')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

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
              child: const ImageIcon(
                AssetImage('lib/assets/arrow_back.png'),
                size: 49,
              ),
            ),
          ),
          title: Text('Đánh giá ${widget.title}'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bạn cảm thấy ${widget.title} thế nào?',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Đánh giá tổng thể',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: _selectedStars > index
                              ? Colors.amber
                              : const Color.fromARGB(255, 221, 220, 220),
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
                  const SizedBox(height: 8),
                  const Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
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
                          controller: _reviewController,
                          maxLength: 1000, // Giới hạn số ký tự tối đa
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'Gõ vào đây',
                            contentPadding: const EdgeInsets.all(16),
                            counter: Text(
                              '${_reviewController.text.length}/1000', // Hiển thị số ký tự hiện tại
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          onChanged: (text) {
                            // Cập nhật trạng thái để hiển thị số ký tự hiện tại
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.camera_alt_outlined),
                                    Text('Thêm hình ảnh'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing:
                                      8, // Khoảng cách ngang giữa các hình ảnh
                                  runSpacing:
                                      8, // Khoảng cách dọc giữa các hàng hình ảnh
                                  children: [
                                    // Hiển thị hình ảnh đã chọn
                                    for (var image in _imageFiles)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Image.file(
                                          image,
                                          width:
                                              100, // Đặt chiều rộng theo ý muốn
                                          height:
                                              100, // Đặt chiều cao theo ý muốn
                                          fit: BoxFit
                                              .cover, // Để hình ảnh tự động điều chỉnh
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Action for "Bỏ qua" button
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(59, 99, 53, 1),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(13),
                                  child: Text(
                                    'Bỏ qua',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: (_isLoading || _selectedStars == 0)
                                    ? null // Disable button if loading
                                    : () async {
                                        setState(() {
                                          _isLoading = true; // Start loading
                                        });
                                        await _submitReview();
                                        setState(() {
                                          _isLoading =
                                              false; // End loading after submission
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(59, 99, 53, 1),
                                  foregroundColor: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height:
                                              20, // Fixed height for the button
                                          width:
                                              20, // Fixed width for the button
                                          child: CircularProgressIndicator(
                                            color: Colors
                                                .white, // Progress indicator color
                                            strokeWidth:
                                                2, // Thickness of the loading indicator
                                          ),
                                        )
                                      : const Text(
                                          'Xác nhận',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
