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
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeThumua extends StatefulWidget {
  const HomeThumua({super.key});

  @override
  State<HomeThumua> createState() => _HomeThumuaState();
}

class _HomeThumuaState extends State<HomeThumua>
    with SingleTickerProviderStateMixin {
  final BlogApiService _blogApiService = BlogApiService();
  List<BlogModel> _blogPosts = [];
  String? userId;
  String? chooseRole;
  bool isLoading = true; // Track loading state
  String? image;
  late TabController _tabController; // Khai báo TabController

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged); // Listen for tab changes
    _loadChooseRole();
    _fetchBlogPosts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      _fetchBlogPosts(); // Fetch posts for "Hiện Tại" tab
    } else if (_tabController.index == 1) {
      _fetchBlogPostsFollowing(); // Fetch posts for "Đang Theo Dõi" tab
    }
  }

  Future<void> _loadChooseRole() async {
    setState(() {
      isLoading = true; // Hiển thị trạng thái loading
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      chooseRole = prefs.getString('chooseRole');
      image = prefs.getString('anhDaiDien');
      isLoading = false; // Đã tải xong
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true; // Hiển thị trạng thái loading
    });

    try {
      // Check which tab is selected and call the corresponding API
      if (_tabController.index == 0) {
        await _fetchBlogPosts(); // Fetch posts for "Hiện Tại" tab
      } else if (_tabController.index == 1) {
        await _fetchBlogPostsFollowing(); // Fetch posts for "Đang Theo Dõi" tab
      }
    } catch (error) {
      print('Lỗi khi tải dữ liệu: $error');
    } finally {
      setState(() {
        isLoading = false; // Ẩn trạng thái loading
      });
    }
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
      // Fetch the blog posts
      List<BlogModel> blogPosts = await _blogApiService.getListBaiViet(userId!);

      // Sắp xếp theo bài viết mới nhất (giả sử `createdAt` là kiểu DateTime)
      blogPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return; // Check again before updating state
      setState(() {
        _blogPosts = blogPosts; // Update sorted blog posts
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

  Future<void> _fetchBlogPostsFollowing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (!mounted) return; // Check if widget is still in the tree
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      // Fetch the blog posts
      List<BlogModel> blogPosts =
          await _blogApiService.getListBaiVietTheoDoi(userId!);

      // Sắp xếp theo bài viết mới nhất (giả sử `createdAt` là kiểu DateTime)
      blogPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return; // Check again before updating state
      setState(() {
        _blogPosts = blogPosts; // Update sorted blog posts
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
              return Stack(
                children: [
                  // Your existing content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 20),
                        AppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          title: Text(
                            "Bình luận(${post.binhluan.length})",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          centerTitle: true,
                        ),
                        const SizedBox(height: 10),
                        post.binhluan.isEmpty
                            ? const Expanded(
                                child: Center(
                                  child: Text(
                                    "Chưa có bình luận nào",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: post.binhluan.length,
                                  itemBuilder: (context, index) {
                                    final PhanHoi comment =
                                        post.binhluan[index];
                                    final user = comment.userId;
                                    final userName =
                                        user.tenNguoiDung ?? 'Unknown User';
                                    final userImage = user.anhDaiDien;

                                    final isCurrentUser =
                                        user.id == currentUserId;
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
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                            Icons
                                                                .account_circle,
                                                            size: 30);
                                                      },
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.account_circle),
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
                                  decoration: InputDecoration(
                                    hintText: "Viết bình luận...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                          color: Color.fromRGBO(41, 87, 35, 1)),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () async {
                                  if (isLoading) return;

                                  setState(() {
                                    isLoading = true;
                                  });

                                  final userId = prefs.getString('userId');
                                  final name = prefs.getString('tenNguoiDung');

                                  final newComment =
                                      commentController.text.trim();
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
                                        isLoading =
                                            false; // Set loading to false after the API call
                                      });

                                      onCommentAdded();
                                    } catch (e) {
                                      setState(() {
                                        isLoading =
                                            false; // Set loading to false in case of error
                                      });
                                      print('Failed to add comment: $e');
                                    }
                                  } else if (userId == null) {
                                    setState(() {
                                      isLoading =
                                          false; // Set loading to false if user ID is null
                                    });
                                    print('Error: User ID is null.');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Overlay with loading indicator
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5), // Dark overlay
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color.fromRGBO(41, 87, 35, 1),),
                        ),
                      ),
                    ),
                ],
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              if (chooseRole != 'khachmuahang') ...[
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
                          ),
                        ),
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
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/creat_blog_screen')
                        .then((result) {
                      if (result == true) {
                        _fetchBlogPosts(); // Tải lại dữ liệu
                      }
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: image != null && image!.isNotEmpty
                                ? NetworkImage(image!)
                                : null,
                            child: image == null || image!.isEmpty
                                ? const Icon(
                                    Icons.account_circle,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 9,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: const Border.fromBorderSide(BorderSide(
                                  color: Color.fromARGB(255, 184, 182, 182))),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Color.fromRGBO(41, 87, 35, 1),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color.fromRGBO(41, 87, 35, 1),
                  tabs: const [
                    Tab(text: 'Dành cho bạn'),
                    Tab(text: 'Đang Theo Dõi'),
                  ],
                ),
              ),
              // Using Expanded here to ensure the TabBarView fills available space.
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // "Hiện Tại" Tab
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(41, 87, 35, 1),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: _blogPosts
                                  .map((post) => _buildPostItem(post))
                                  .toList(),
                            ),
                          ),
                    // "Đang Theo Dõi" Tab
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(41, 87, 35, 1),),),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: _blogPosts
                                  .map((post) => _buildPostItem(post))
                                  .toList(),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(BlogModel post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
              spreadRadius: 2, // Bán kính lan rộng của bóng
              blurRadius: 5, // Độ mờ của bóng
              offset: const Offset(0, 3), // Độ dịch chuyển của bóng
            ),
          ],
        ),
        child: Column(
          children: [
            // Header (User info and post title)
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
                      ),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 27, right: 27),
                child: ReadMoreText(
                  post.noidung,
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "Xem Thêm",
                  trimExpandedText: "Ẩn",
                  moreStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Color.fromRGBO(248, 158, 25, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(248, 158, 25, 1)),
                  lessStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Color.fromRGBO(248, 158, 25, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(248, 158, 25, 1)),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            // Post image
            if (post.image.isNotEmpty)
              SizedBox(
                width: double.infinity,
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
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'lib/assets/avt2.jpg',
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
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
                                          'lib/assets/avt2.jpg',
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
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            // Likes and comments section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          setState(() {});
                        },
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(size: 20, Icons.comment_outlined),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "${post.binhluan.length}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
