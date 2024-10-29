import 'package:don_ganh_app/api_services/review_api_service.dart';
import 'package:don_ganh_app/models/review_model.dart';
import 'package:don_ganh_app/widget/review_widget.dart';
import 'package:flutter/material.dart';

class AllReviewsPage extends StatefulWidget {
  final String productId;

  const AllReviewsPage({super.key, required this.productId});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  late Future<List<DanhGia>> _reviewsFuture;
  int? selectedRating; // Biến lưu trữ xếp hạng được chọn
  List<int> ratings = [1, 2, 3, 4, 5]; // Các xếp hạng có sẵn

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewApiService().getReviewsByProductId(widget.productId);
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture = ReviewApiService().getReviewsByProductId(widget.productId);
    });
  }

  Future<List<DanhGia>> _getFilteredReviews() async {
    final reviews = await _reviewsFuture;
    if (selectedRating == null) {
      return reviews; // Nếu không có xếp hạng nào được chọn, trả về tất cả đánh giá
    }
    // Lọc danh sách đánh giá theo xếp hạng
    return reviews.where((review) => review.xepHang == selectedRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá'),
      ),
      body: Column(
        children: [
          // Dropdown menu để chọn xếp hạng
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButton<int>(
              hint: const Text('Chọn xếp hạng'),
              value: selectedRating,
              items: ratings.map((rating) {
                return DropdownMenuItem<int>(
                  value: rating,
                  child: Row(
                    children: [
                      // Hiển thị số sao tương ứng
                      ...List.generate(rating, (index) => const Icon(Icons.star, color: Colors.amber)),
                      const SizedBox(width: 8), // Khoảng cách giữa sao và số
                      Text(rating.toString()), // Hiển thị số xếp hạng
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRating = value; // Cập nhật xếp hạng được chọn
                });
              },
            ),
          ),
          // Nút để hiển thị tất cả đánh giá
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedRating = null; // Đặt lại bộ lọc
              });
            },
            child: const Text('Hiển thị tất cả'),
          ),
          Expanded(
            child: FutureBuilder<List<DanhGia>>(
              future: _getFilteredReviews(), // Gọi hàm lọc đánh giá
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reviews available.'));
                }

                // Hiển thị danh sách đánh giá đã lọc
                final reviews = snapshot.data!;
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ReviewItem(
                      review: review,
                      onDelete: _refreshReviews,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
