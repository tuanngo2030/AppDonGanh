import 'dart:io';
import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatBlogScreen extends StatefulWidget {
  const CreatBlogScreen({super.key});

  @override
  State<CreatBlogScreen> createState() => _CreatBlogScreenState();
}

class _CreatBlogScreenState extends State<CreatBlogScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isFormValid = false;
  String? userId;

  final BlogApiService _blogApiService = BlogApiService();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateForm);
    _contentController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Check if the form is valid
  void _validateForm() {
    setState(() {
      _isFormValid = _titleController.text.isNotEmpty &&
          _contentController.text.isNotEmpty;
    });
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

  // Submit blog post
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
      await _blogApiService.createBaiViet(
        userId: userId,
        tieude: _titleController.text,
        noidung: _contentController.text,
        tags: _tagsController.text.split(','),
        imageFiles: _selectedImages,
      );

      // After successful submission, clear fields or navigate back
      setState(() {
        _titleController.clear();
        _contentController.clear();
        _tagsController.clear();
        _selectedImages.clear();
        _isFormValid = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài viết đã được đăng thành công!')),
      );

      // Optionally, navigate back
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng bài viết thất bại: $e')),
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
                              "Tạo bài viết",
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
                          onPressed:
                              _isFormValid && !_isLoading ? _submitPost : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: _isFormValid && !_isLoading
                                ? const Color.fromRGBO(59, 99, 53, 1)
                                : Colors.white,
                            backgroundColor: _isFormValid && !_isLoading
                                ? Colors.white
                                : Colors.grey,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "Đăng",
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

                // User information and image picker
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Row(
                    children: [
                      Image.asset('lib/assets/logo_app.png'),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HiHi'),
                          ],
                        ),
                      ),
                    ],
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
