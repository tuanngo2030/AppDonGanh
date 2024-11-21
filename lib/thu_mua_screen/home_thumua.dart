import 'package:carousel_slider/carousel_slider.dart';
import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:don_ganh_app/api_services/comment_api_service.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/thu_mua_screen/other_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeThumua extends StatefulWidget {
  const HomeThumua({super.key});

  @override
  State<HomeThumua> createState() => _HomeThumuaState();
}

class _HomeThumuaState extends State<HomeThumua> {
  final BlogApiService _blogApiService = BlogApiService();
  List<BlogModel> _blogPosts = [];
  String? userId;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
  }

 void showFullScreenImages(
    BuildContext context, List<String> images, int initialIndex) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: images.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'lib/assets/avt2.jpg', // Hình ảnh thay thế
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: PageController(initialPage: initialIndex),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


 Future<void> _fetchBlogPosts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (!mounted) return; // Check if widget is still in the tree
  setState(() {
    isLoading = true; // Show loading indicator
  });

  try {
    List<BlogModel> blogPosts = await _blogApiService
        .getListBaiViet(userId!); // Replace with actual user ID
    if (!mounted) return; // Check again before updating state
    setState(() {
      _blogPosts = blogPosts;
    });
  } catch (e) {
    print('Error fetching blog posts: $e');
  } finally {
    if (!mounted) return; // Final check
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }
}

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return DateFormat('dd-MM-yyyy').format(date); // Adjust the format as needed
  }

  Future<void> _toggleLike(String baivietId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    // Find the index of the post in the list
    final postIndex = _blogPosts.indexWhere((post) => post.id == baivietId);
    if (postIndex == -1) return;

    // Toggle like status immediately on the UI
    setState(() {
      final post = _blogPosts[postIndex];
      if (post.likes.contains(userId)) {
        post.likes.remove(userId); // Unlike
        post.isLiked = false;
      } else {
        post.likes.add(userId); // Like
        post.isLiked = true;
      }
    });

    try {
      // Call API to update like status
      await _blogApiService.updateLike(baivietId, userId);
    } catch (error) {
      // If there's an error, revert the like status
      setState(() {
        final post = _blogPosts[postIndex];
        if (post.likes.contains(userId)) {
          post.likes.remove(userId); // Revert to unlike
          post.isLiked = false;
        } else {
          post.likes.add(userId); // Revert to like
          post.isLiked = true;
        }
      });

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like status: $error')),
      );
    }
  }

  void _showComments(
      BuildContext context, BlogModel post, Function() onCommentAdded) {
    final TextEditingController commentController = TextEditingController();
    final commentApiService = CommentApiService();

    SharedPreferences.getInstance().then((prefs) {
      final currentUserId = prefs.getString('userId');

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Bình luận (${post.binhluan.length})",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    post.binhluan.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                "Chưa có bình luận nào",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: post.binhluan.length,
                              itemBuilder: (context, index) {
                                final PhanHoi comment = post.binhluan[index];
                                final user = comment.userId;
                                final userName =
                                    user.tenNguoiDung ?? 'Unknown User';
                                final userImage = user.anhDaiDien;

                                final isCurrentUser = user.id == currentUserId;
                                final displayName = isCurrentUser
                                    ? "$userName (bạn)"
                                    : userName;

                                return GestureDetector(
                                  onLongPress: () {
                                    _showCommentOptions(
                                      context,
                                      isCurrentUser,
                                      comment,
                                      post.id,
                                      (updatedComment) {
                                        setState(() {
                                          post.binhluan[index].binhLuan =
                                              updatedComment;
                                        });
                                      },
                                      post,
                                      setState, // Pass setState to update the parent widget
                                    );
                                  },
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        userImage != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  height: 30,
                                                  width: 30,
                                                  userImage,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.account_circle,
                                                        size: 30);
                                                  },
                                                ),
                                              )
                                            : const Icon(Icons.account_circle),
                                        const SizedBox(width: 8),
                                        Text(displayName),
                                      ],
                                    ),
                                    subtitle: Text(comment.binhLuan ?? ''),
                                    trailing: Text(
                                      "${comment.ngayTao.day}/${comment.ngayTao.month}/${comment.ngayTao.year}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: "Viết bình luận...",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              final userId = prefs.getString('userId');
                              final name = prefs.getString('tenNguoiDung');

                              final newComment = commentController.text.trim();
                              if (newComment.isNotEmpty && userId != null) {
                                try {
                                  List<PhanHoi> updatedComments =
                                      await commentApiService.addBinhLuan(
                                    baivietId: post.id,
                                    userId: userId,
                                    binhLuan: newComment,
                                  );

                                  commentController.clear();

                                  setState(() {
                                    post.binhluan = updatedComments;
                                  });

                                  onCommentAdded();
                                } catch (e) {
                                  print('Failed to add comment: $e');
                                }
                              } else if (userId == null) {
                                print('Error: User ID is null.');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  void _showCommentOptions(
    BuildContext context,
    bool isCurrentUser,
    PhanHoi comment,
    String baivietId,
    Function(String) onCommentEdited,
    BlogModel post,
    Function setState, // Passing setState to parent widget
  ) {
    final commentApiService = CommentApiService();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (isCurrentUser) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa bình luận'),
                onTap: () async {
                  Navigator.pop(context);

                  // Show dialog to edit comment
                  final updatedComment = await _showEditCommentDialog(
                      context, comment.binhLuan ?? '');

                  if (updatedComment != null) {
                    // Call update API
                    bool success = await commentApiService.updateComment(
                      baivietId: baivietId,
                      binhLuanId: comment.id,
                      updatedComment: updatedComment,
                    );

                    // If update is successful, call the onCommentEdited callback
                    if (success) {
                      onCommentEdited(updatedComment);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Xóa bình luận'),
                onTap: () {
                  _showDeleteConfirmationDialog(
                    context,
                    context,
                    comment,
                    baivietId,
                    post,
                    () {
                      setState(() {
                        post.binhluan.removeWhere((c) =>
                            c.id == comment.id); // Remove comment from list
                      });
                    },
                  );
                },
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Báo cáo bình luận'),
                onTap: () {
                  // Add report logic here
                },
              ),
          ],
        );
      },
    );
  }

// Helper function to show an edit dialog and get updated comment text
  Future<String?> _showEditCommentDialog(
      BuildContext context, String currentComment) async {
    final TextEditingController editController =
        TextEditingController(text: currentComment);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa bình luận'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Nhập bình luận mới"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, editController.text);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext rootContext,
    BuildContext dialogContext,
    PhanHoi comment,
    String baivietId,
    BlogModel post,
    Function() onCommentDeleted,
  ) {
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa bình luận này không?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Xóa"),
              onPressed: () async {
                Navigator.of(context).pop();
                final commentApiService = CommentApiService();

                bool isDeleted = await commentApiService.deleteBinhLuan(
                  baivietId: baivietId,
                  binhLuanId: comment.id,
                );

                // If deletion is successful, remove the comment from the list and update UI
                if (isDeleted) {
                  setState(() {
                    post.binhluan.removeWhere((c) =>
                        c.id == comment.id); // Remove comment from the list
                  });

                  onCommentDeleted(); // Trigger callback to update comment count in the parent widget

                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                        content: Text('Bình luận đã được xóa thành công')),
                  );
                } else {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(content: Text('Xóa bình luận thất bại')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header and input fields as in your original code...
              Container(
                color: const Color.fromRGBO(59, 99, 53, 1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: 100,
                          width: 200,
                          child: Image.asset(
                            'lib/assets/logo_xinchao.png',
                            fit: BoxFit.contain,
                          )),
                      GestureDetector(
                        onTap: () {
                          print('Setting');
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: Image.asset('lib/assets/caidat_icon.png'),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/creat_blog_screen');
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50)),
                        child: Image.asset('lib/assets/fb_icon.png',
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: 300,
                        decoration: BoxDecoration(
                            border: const Border.fromBorderSide(BorderSide(
                                color: Color.fromARGB(255, 184, 182, 182))),
                            borderRadius: BorderRadius.circular(50)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đăng bài viết của bạn.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 158, 156, 156),
                                ),
                              ),
                              Icon(Icons.camera_alt_outlined),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(), // Loading indicator
                    )
                  : Column(
                      children: _blogPosts
                          .map((post) => _buildPostItem(post))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(BlogModel post) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        child: Column(
          children: [
            // User info and post title
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('userId');
                userId == post.userId.id
                    ? Navigator.pushNamed(context, '/your_blog_screen')
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => O(
                            nguoiDung: post.userId,
                          ),
                        ),
                      );
              },
              child: ListTile(
                leading: post.userId.anhDaiDien != null
                    ? ClipOval(
                        child: Image.network(
                          post.userId.anhDaiDien!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 40,
                            ); // Default icon if image fails to load
                          },
                        ),
                      )
                    : const Icon(
                        Icons.account_circle,
                        size: 40,
                      ), //
                title: Text(
                  userId == post.userId.id
                      ? '${post.userId.tenNguoiDung} (bạn)'
                      : '${post.userId.tenNguoiDung}',
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(fontSize: 10),
                    ),
                    if (post.isUpdate == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          '(Đã chỉnh sửa)',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Post content
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, bottom: 20),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(post.noidung ?? '')),
            ),

            // Post image (only if it exists)
            if (post.image.isNotEmpty)
              SizedBox(
                width: double
                    .infinity, // Ensure the container takes the full width
                child: GestureDetector(
                  onTap: () {
                    showFullScreenImages(context, post.image, 0);
                  },
                  child: post.image.length == 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              post.image[0],
                              width: double.infinity, // Full width
                              fit: BoxFit
                                  .contain, // Ensures the image maintains its aspect ratio
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'lib/assets/avt2.jpg', // Đường dẫn tới ảnh thay thế
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox(
                          height:
                              200, // You can set height here, or adjust based on your UI
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.image.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showFullScreenImages(
                                      context, post.image, index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      post.image[index],
                                      width: 220,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'lib/assets/avt2.jpg', // Đường dẫn tới ảnh thay thế
                                          width: 220,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),

            // Likes and comments section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleLike(post.id),
                        child: Row(
                          children: [
                            Icon(
                              size: 20,
                              post.isLiked == true
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: post.isLiked == true
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                "${post.likes.length}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _showComments(
                        context,
                        post,
                        () {
                          setState(() {
                            // After updating comments (deleting or adding),
                            // the comment count will automatically reflect the latest count
                          });
                        },
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(size: 20, Icons.comment_outlined),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "${post.binhluan.length}", // Make sure this reflects the latest comment count
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1),
          ],
        ),
      ),
    );
  }
}
