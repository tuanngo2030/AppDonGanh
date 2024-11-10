import 'dart:io';
import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class EditBlogScreen extends StatefulWidget {
  final BlogModel blog;

  const EditBlogScreen({super.key, required this.blog});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isLoading = false;
  String? userId;

  final BlogApiService _blogApiService = BlogApiService();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data
    _titleController.text = widget.blog.tieude;
    _contentController.text = widget.blog.noidung;
    _tagsController.text = widget.blog.tags.join(', ');

    // Load existing images from the network
    _loadImagesFromNetwork();
  }

  // Function to load images from network URLs
  Future<void> _loadImagesFromNetwork() async {
    List<File> downloadedImages = [];
    for (String imageUrl in widget.blog.image) {
      final File file = await _downloadImage(imageUrl);
      downloadedImages.add(file);
    }

    setState(() {
      _selectedImages = downloadedImages;
    });
  }

  // Function to download an image from the network
  Future<File> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      throw Exception('Failed to load image');
    }
  }

  // Image picker
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() {
      _selectedImages = images.map((e) => File(e.path)).toList();
    });
  }

  // Remove image from selected images list
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Submit blog post update
  Future<void> _submitPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      // Handle user ID not found
      print("User not logged in");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure we're passing only the final list of images after removal
      await _blogApiService.updateBaiViet(
        baivietId: widget.blog.id,
        userId: userId,
        tieude: _titleController.text,
        noidung: _contentController.text,
        tags: _tagsController.text,
        files: _selectedImages, // This is the updated list after removal
      );

      // After successful submission, clear fields or navigate back
      setState(() {
        _titleController.clear();
        _contentController.clear();
        _tagsController.clear();
        _selectedImages.clear(); // Clear images after successful update
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài viết đã được cập nhật thành công!')),
      );

      // Optionally, navigate back
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật bài viết thất bại: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                // AppBar-like container
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(59, 99, 53, 1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color.fromRGBO(59, 99, 53, 1),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              "Chỉnh sửa bài viết",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor:
                                const Color.fromRGBO(59, 99, 53, 1),
                            backgroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "Cập nhật",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Title input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Nhập tiêu đề",
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),

                // Content input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextFormField(
                    controller: _contentController,
                    maxLines: 15,
                    minLines: 10,
                    decoration: const InputDecoration(
                      hintText: "Đăng bài viết của bạn.",
                      contentPadding: EdgeInsets.all(25),
                    ),
                  ),
                ),

                // Tags input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: "Nhập tags (cách nhau bởi dấu phẩy)",
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),

                // Image picker button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text("Chọn hình ảnh"),
                  ),
                ),

                // Display selected images with delete button
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedImages.map((image) {
                    int index = _selectedImages.indexOf(image);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.file(image, width: 100, height: 100),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 12,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
