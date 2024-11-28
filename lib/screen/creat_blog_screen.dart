import 'dart:io';
import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String? tenNguoiDung;
  String? anhDaiDien;
  final BlogApiService _blogApiService = BlogApiService();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateForm);
    _contentController.addListener(_validateForm);
    _loadUserData();
    _checkPermissions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _titleController.text.isNotEmpty &&
          _contentController.text.isNotEmpty;
    });
  }
Future<void> _checkPermissions() async {
  PermissionStatus cameraPermission = await Permission.camera.status;
  if (cameraPermission.isDenied) {
    await Permission.camera.request();
  }
}
  Future<void> _takePhoto() async {
    // Check and request camera permission
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } else if (status.isDenied) {
      // Permission is denied, show a message or ask the user to enable it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Camera permission is required to take a photo")),
      );
    } else if (status.isPermanentlyDenied) {
      // User has permanently denied permission, open settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Camera permission is permanently denied. Please enable it in settings.")),
      );
      openAppSettings();
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() {
      _selectedImages = images.map((e) => File(e.path)).toList();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
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

      setState(() {
        _titleController.clear();
        _contentController.clear();
        _tagsController.clear();
        _selectedImages.clear();
        _isFormValid = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài viết đã được đăng thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng bài viết thất bại: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tenNguoiDung = prefs.getString('tenNguoiDung') ?? 'Tên người dùng';
      anhDaiDien = prefs.getString('anhDaiDien') ?? 'lib/assets/avatar2.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
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
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
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

            // User info and content input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              anhDaiDien != null && anhDaiDien!.isNotEmpty
                                  ? NetworkImage(
                                      anhDaiDien!) // Dùng ảnh từ URL nếu hợp lệ
                                  : AssetImage('lib/assets/avt1.jpg')
                                      as ImageProvider, // Ảnh mặc định
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenNguoiDung ?? 'Tên người dùng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(tenNguoiDung ?? 'Tên người dùng'),
                          ],
                        ),
                      ],
                    ),
                    // Title input field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: "Nhập tiêu đề",
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),

                    const SizedBox(height: 15),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Đăng bài viết của bạn.",
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

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

            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionButton(
                      imagePath:
                          "lib/assets/anhvideo.png", // Replace with your image path
                      label: "Ảnh/video",
                      onPressed: _pickImages,
                    ),
                  ),
                  Container(
                    width: 1, // Thickness of the line
                    color: Colors.grey, // Color of the line
                    height: 50, // Adjust the height
                  ),
                  Expanded(
                    child: _buildActionButton(
                      imagePath:
                          "lib/assets/chupanhicon.png", // Replace with your image path
                      label: "Chụp",
                      onPressed: _takePhoto,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey,
                    height: 50,
                  ),
                  Expanded(
                    child: _buildActionButton(
                      imagePath:
                          "lib/assets/tagicon.png", // Replace with your image path
                      label: "Tag",
                      onPressed: () {
                        print("Thêm tag");
                      },
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

  Widget _buildActionButton({
    required String imagePath, // Path to the image
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 20, // Adjust the icon size
            height: 20,
          ),
          const SizedBox(width: 8), // Space between icon and text
          Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(
                    255, 0, 0, 0)), // Customize font size and color
          ),
        ],
      ),
    );
  }
}
