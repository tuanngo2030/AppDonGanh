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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<DanhGia>>(
          future: ReviewApiService().getReviewsByProductId(widget.productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No reviews available.'));
            }
        
            // Get the most recent two reviews
            final reviews = snapshot.data!;
        
            // Display the list of recent reviews
            return SizedBox(
              child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ReviewItem(
                    review: review,
                    onDelete: _refreshReviews,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
