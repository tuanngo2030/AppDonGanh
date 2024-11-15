import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:don_ganh_app/api_services/comment_api_service.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostItem extends StatefulWidget {
  final BlogModel post;

  const PostItem({super.key, required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final BlogApiService _blogApiService = BlogApiService();
  String? userId;

  Future<List<BlogModel>>? _userBlogs;
  Future<List<Map<String, dynamic>>>? _userProducts;

  @override
  void initState() {
    super.initState();
    // _fetchBlogPosts;
    _loadUserProducts;
  }

  Future<void> _loadUserProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    String SetuserId = '67054001d6a6039bcca389fa';
    final response = await UserApiService().fetchUserData(SetuserId, userId!);

    setState(() {
      final blogData =
          response['baiViet']['list']; // Adjust based on actual JSON key
      if (blogData is List) {
        _userBlogs = Future(
            () => blogData.map((json) => BlogModel.fromJson(json)).toList());
      } else {
        _userBlogs = Future.value([]);
      }
    });
  }

  Future<void> _toggleLike(String baivietId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    // Optimistic UI update: update the UI immediately
    bool isLiked = widget.post.likes.contains(userId);
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(userId); // Unlike
        widget.post.isLiked = false;
      } else {
        widget.post.likes.add(userId); // Like
        widget.post.isLiked = true;
      }
    });

    try {
      // Call API to update like status
      await _blogApiService.updateLike(baivietId, userId);
    } catch (error) {
      // If the API call fails, revert the like status
      setState(() {
        if (isLiked) {
          widget.post.likes.add(userId); // Revert to like
          widget.post.isLiked = true;
        } else {
          widget.post.likes.remove(userId); // Revert to unlike
          widget.post.isLiked = false;
        }
      });

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like status: $error')),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return DateFormat('dd-MM-yyyy').format(date); // Adjust the format as needed
  }

  void _handleMenuSelection(String value, String postId, BlogModel post) {
    // Handle menu options (edit/delete)
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
    // print("isLiked value: ${post.isLiked}");
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        child: Column(
          children: [
            ListTile(
              leading: widget.post.userId.anhDaiDien != null
                  ? ClipOval(
                      child: Image.network(
                        widget.post.userId.anhDaiDien!,
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
                widget.post.userId.tenNguoiDung ?? 'Unknown User',
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Row(
                children: [
                  Text(
                    _formatDate(widget.post.createdAt),
                    style: const TextStyle(fontSize: 10),
                  ),
                  if (widget.post.isUpdate == true)
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
                    _handleMenuSelection(value, widget.post.id, widget.post),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                        value: 'report', child: Text('Báo cáo')),
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
                child: Text(widget.post.noidung ?? ''),
              ),
            ),
            // Post image (only if it exists)
            if (widget.post.image.isNotEmpty)
              SizedBox(
                height: 200,
                child: widget.post.image.length == 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            widget.post.image[0],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.post.image.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                widget.post.image[index],
                                height: 100,
                                width: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'lib/assets/avt2.jpg', // Path to your fallback image
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  );
                                },
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
                  GestureDetector(
                    onTap: () => _toggleLike(widget.post.id),
                    child: Row(
                      children: [
                        Icon(
                          size: 20,
                          widget.post.isLiked == true
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          color: widget.post.isLiked == true
                              ? Colors.blue
                              : Colors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "${widget.post.likes.length}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _showComments(context, widget.post, () {
                        setState(() {});
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(size: 20, Icons.comment_outlined),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "${widget.post.binhluan.length}",
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
