import 'package:don_ganh_app/api_services/review_api_service.dart';
import 'package:don_ganh_app/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewItem extends StatefulWidget {
  final DanhGia review;
  final Function onDelete;

  const ReviewItem({
    super.key,
    required this.review,
    required this.onDelete,
  });

  @override
  _ReviewItemState createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool _showResponses = false;
  String? _currentUserId;
  final ReviewApiService reviewApiService =
      ReviewApiService(); // Instantiate API service
  late bool _isLiked; // Track if the review is liked by the current user

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _isLiked =
        widget.review.isLiked; // Initialize the like status based on the review
  }

  Future<void> _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        _showEditDialog();

        break;
      case 'delete':
        _deleteReview();
        break;
      case 'report':
        // Handle report action
        break;
    }
  }

  void _showEditDialog() {
    TextEditingController commentController =
        TextEditingController(text: widget.review.binhLuan);
    int selectedRating =
        widget.review.xepHang; // Initially set to the current rating

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Use StatefulBuilder to update the stars dynamically
            return AlertDialog(
              title: const Text('Chỉnh sửa đánh giá'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Bình luận'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating =
                                index + 1; // Update selected rating
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog without saving
                  },
                ),
                TextButton(
                  child: const Text('Lưu'),
                  onPressed: () {
                    _updateReview(commentController.text,
                        selectedRating); // Pass the updated rating
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateReview(String newComment, int newRating) async {
    try {
      await reviewApiService.updateReview(
        danhGiaId: widget.review.id,
        xepHang: newRating,
        binhLuan: newComment,
      );

      // Update local review object after successful API call
      setState(() {
        widget.review.binhLuan = newComment;
        widget.review.xepHang = newRating;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đánh giá đã được cập nhật')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật đánh giá: $error')),
      );
    }
  }

  Future<void> _deleteReview() async {
    try {
      await reviewApiService.deleteReview(
          widget.review.sanphamId, widget.review.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đánh giá đã được xóa')),
      );
      widget.onDelete();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa đánh giá: $error')),
      );
    }
  }

  Future<void> _updateLike() async {
    if (_currentUserId != null) {
      // Toggle like status immediately
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          // User likes the review
          widget.review.likes.add(_currentUserId!);
        } else {
          // User unlikes the review
          widget.review.likes.remove(_currentUserId!);
        }
      });

      try {
        // Now make the API call to update the like status
        await reviewApiService.updateLike(widget.review.id, _currentUserId!);
      } catch (error) {
        // If there's an error, revert the like status
        setState(() {
          _isLiked = !_isLiked; // Revert the like status
          if (_isLiked) {
            widget.review.likes.remove(_currentUserId!);
          } else {
            widget.review.likes.add(_currentUserId!);
          }
        });

        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thích đánh giá: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 27),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.review.userId.anhDaiDien !=
                                  null
                              ? NetworkImage(widget.review.userId.anhDaiDien!)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                          radius: 15,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _currentUserId == widget.review.userId.id
                                      ? '${widget.review.userId.tenNguoiDung} (Bạn)'
                                      : widget.review.userId.tenNguoiDung!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: index < widget.review.xepHang
                                      ? Colors.amber
                                      : Colors.grey,
                                  size: 18,
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(widget.review.binhLuan),
                    Text(widget.review.ngayTao
                        .toLocal()
                        .toString()
                        .split(' ')[0]),

                    // Hiển thị hình ảnh
                    // Hiển thị hình ảnh
                    if (widget.review.HinhAnh.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0, // Khoảng cách giữa các hình ảnh
                        children: widget.review.HinhAnh.map((imageUrl) {
                          return Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null)
                                return child; // Hiện hình ảnh khi tải xong
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              ); // Hiện progress indicator trong lúc tải
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return const Text(
                                  'Không thể tải hình ảnh'); // Hiện thông báo lỗi nếu tải không thành công
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showResponses = !_showResponses;
                        });
                      },
                      child: Text(
                        _showResponses
                            ? 'Ẩn phản hồi'
                            : 'Xem phản hồi (${widget.review.phanHoi.length})',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      size: 15,
                      color: _isLiked
                          ? const Color.fromRGBO(41, 87, 35, 1)
                          : null, // Change color based on like status
                    ),
                    onPressed: _updateLike, // Call the like function
                  ),
                  Text(
                    'Hữu ích(${widget.review.likes.length})',
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between the text and popup menu
                  PopupMenuButton<String>(
                    onSelected: _handleMenuSelection,
                    itemBuilder: (context) {
                      return _currentUserId == widget.review.userId.id
                          ? [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Sửa')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Xóa')),
                            ]
                          : [
                              const PopupMenuItem(
                                  value: 'report', child: Text('Báo cáo')),
                            ];
                    },
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showResponses) ...[
          for (var response in widget.review.phanHoi.take(2)) ...[
            Padding(
              padding: const EdgeInsets.only(left: 54, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Người dùng: ${response.userId}'),
                  Text('Nội dung: ${response.binhLuan}'),
                  Text(
                      'Ngày: ${response.ngayTao.toLocal().toString().split(' ')[0]}'),
                  const Divider(),
                ],
              ),
            ),
          ],
        ],
        const Divider(),
      ],
    );
  }
}
