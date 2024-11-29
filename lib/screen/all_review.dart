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
  int? selectedRating; // Variable to store selected rating
  List<int> ratings = [1, 2, 3, 4, 5]; // Available ratings

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewApiService().getReviewsByProductId(widget.productId);
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture =
          ReviewApiService().getReviewsByProductId(widget.productId);
    });
  }

  Future<List<DanhGia>> _getFilteredReviews() async {
    final reviews = await _reviewsFuture;
    if (selectedRating == null) {
      return reviews; // If no rating is selected, return all reviews
    }
    // Filter reviews by selected rating
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
          // Row containing the button and dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                // Square button to display all reviews with a border based on selection
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = null; // Reset filter
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // color: selectedRating == null ? Colors.blue : Colors.white,
                      border: Border.all(
                        color: selectedRating == null ?Colors.green  : Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child:  Text(
                      'Hiển thị tất cả',
                      style: TextStyle(
                        color: selectedRating == null ?Colors.green  : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: DropdownButton<int>(
                    hint: const Text('Chọn xếp hạng'),
                    value: selectedRating,
                    items: ratings.map((rating) {
                      return DropdownMenuItem<int>(
                        value: rating,
                        child: Row(
                          children: [
                            // Show corresponding stars
                            ...List.generate(
                                rating,
                                (index) =>
                                    const Icon(Icons.star, color: Colors.amber)),
                            const SizedBox(width: 8), // Space between star and number
                            Text(rating.toString()), // Show rating number
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRating = value; // Update selected rating
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<DanhGia>>(
              future: _getFilteredReviews(), // Call to filter reviews
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Chưa có đánh giá nào.'));
                }

                // Display filtered reviews list
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
