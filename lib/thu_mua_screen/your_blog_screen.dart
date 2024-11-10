import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:don_ganh_app/api_services/comment_api_service.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/thu_mua_screen/edit_blog_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YourBlogScreen extends StatefulWidget {
  const YourBlogScreen({super.key});

  @override
  State<YourBlogScreen> createState() => _YourBlogScreenState();
}

class _YourBlogScreenState extends State<YourBlogScreen> {
  final BlogApiService _blogApiService = BlogApiService();
  List<BlogModel> _blogPosts = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return DateFormat('dd-MM-yyyy').format(date); // Adjust the format as needed
  }

  Future<void> _fetchBlogPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    try {
      List<BlogModel> blogPosts = await _blogApiService
          .getListBaiVietByUserId(userId!); // Replace with actual user ID
      setState(() {
        _blogPosts = blogPosts;
      });
    } catch (e) {
      print('Error fetching blog posts: $e');
    }
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

  Future<void> _deletePost(String baivietId) async {
    try {
      await _blogApiService.deleteBaiViet(baivietId); // Call delete API
      setState(() {
        _blogPosts.removeWhere(
            (post) => post.id == baivietId); // Remove post from list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài viết đã được xóa thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa bài viết: $e')),
      );
    }
  }

  void _handleMenuSelection(String value, String baivietId, BlogModel post) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditBlogScreen(blog: post),
          ),
        );
        break;
      case 'delete':
        _deletePost(baivietId);
        break;
    }
  }

 void _showComments(BuildContext context, BlogModel post) {
  final TextEditingController commentController = TextEditingController();
  final commentApiService = CommentApiService();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder( // Use StatefulBuilder to enable calling setState inside the modal
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                post.binhluan.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text(
                            "Chưa có bình luận nào",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: post.binhluan.length,
                          itemBuilder: (context, index) {
                            final PhanHoi comment = post.binhluan[index];
                            final user = comment.userId;
                            final userName = user.tenNguoiDung ?? 'Unknown User';
                            final userImage = user.anhDaiDien;

                            return ListTile(
                              title: Row(
                                children: [
                                  userImage != null
                                      ? Image.network(
                                          userImage,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.account_circle,
                                            );
                                          },
                                        )
                                      : const Icon(Icons.account_circle),
                                  const SizedBox(width: 8),
                                  Text(userName),
                                ],
                              ),
                              subtitle: Text(comment.binhLuan ?? ''),
                              trailing: Text(
                                "${comment.ngayTao.day}/${comment.ngayTao.month}/${comment.ngayTao.year}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('userId');
                          final name = prefs.getString('tenNguoiDung');

                          final newComment = commentController.text.trim();
                          if (newComment.isNotEmpty && userId != null) {
                            try {
                              // Call API to add comment
                              await commentApiService.addBinhLuan(
                                baivietId: post.id,
                                userId: userId,
                                binhLuan: newComment,
                              );

                              // Clear the input field after sending
                              commentController.clear();

                              // Update the UI with the new comment
                              setState(() {
                                post.binhluan.add(PhanHoi(
                                  id: '', // Assign an actual ID if needed
                                  userId: NguoiDung(id: userId, tenNguoiDung: name), // Use actual user data if available
                                  binhLuan: newComment,
                                  ngayTao: DateTime.now(), // Set to the current date
                                ));
                              });
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
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: const ImageIcon(
                AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
                size: 49, // Kích thước hình ảnh
              ),
            ),
          ),
        ),
        title: const Text('Trang cá nhân'),
      ),
      body: SingleChildScrollView(
        
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0),
                            border: const Border.fromBorderSide(BorderSide(
                                color: Color.fromRGBO(47, 88, 42, 1),
                                width: 2))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image.asset(
                            'lib/assets/avt2.jpg',
                            fit: BoxFit.cover,
                          ),
                        )),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: const Color.fromRGBO(47, 88, 42, 1),
                              border:
                                  Border.all(color: Colors.white, width: 1)),
                          child: const Icon(
                            size: 20,
                            Icons.control_point_outlined,
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Nguyen Thi A',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color.fromRGBO(47, 88, 42, 1)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '45',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Bài viết',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '4589',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Người theo dõi',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '150',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Đang theo dõi',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15, left: 15),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bài viết của bạn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                      )),
                ),
                ..._blogPosts.map((post) => _buildPostItem(post)),
              ],
            ),
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
            ListTile(
              leading: post.userId.anhDaiDien != null
                  ? Image.network(
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
                    )
                  : const Icon(
                      Icons.account_circle,
                      size: 40,
                    ), //
              title: Text(
                post.userId.tenNguoiDung ?? 'Unknown User',
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
              trailing: PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuSelection(value, post.id, post),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ];
                },
                icon: const Icon(Icons.more_horiz),
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
                height: 200, // Adjust height as needed
                child: post.image.length == 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            post.image[0],
                            // Make image full height
                            width: double.infinity, // Make image full width
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.image.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                post.image[index],
                                height:
                                    100, // Regular height for multiple images
                                width: 220, // Regular width for multiple images
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
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
                                  : Colors.grey,
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
                    onTap: () => _showComments(context, post),
                    child: Row(
                      children: [
                        const Icon(size: 20, Icons.comment_outlined),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("${post.binhluan.length ?? 0}",
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Comment input
            const Divider(thickness: 1),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            //   child: Row(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.only(right: 10),
            //         child: Image.asset('lib/assets/logo_app.png'), // User's profile image placeholder
            //       ),
            //       const Expanded(
            //         child: TextField(
            //           decoration: InputDecoration(hintText: 'Bình luận công khai'),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
