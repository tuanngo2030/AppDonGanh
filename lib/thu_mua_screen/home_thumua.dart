import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
  }

  Future<void> _fetchBlogPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    try {
      List<BlogModel> blogPosts = await _blogApiService
          .getListBaiViet(userId!); // Replace with actual user ID
      setState(() {
        _blogPosts = blogPosts;
      });
    } catch (e) {
      print('Error fetching blog posts: $e');
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
                  padding: const EdgeInsets.only(left: 20, right: 20),
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
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50)),
                        child: Image.asset('lib/assets/fb_icon.png',
                            fit: BoxFit.cover),
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
              // Displaying the list of posts
              ..._blogPosts.map((post) => _buildPostItem(post)),
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
                userId == post.userId.id
                    ? '${post.userId.tenNguoiDung} (bạn)'
                    : '${post.userId.tenNguoiDung}' ,
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
                  Row(
                    children: [
                      const Icon(size: 20, Icons.comment_outlined),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text("${post.binhluan.length ?? 0}",
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
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
