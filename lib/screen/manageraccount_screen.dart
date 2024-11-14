import 'dart:io';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:don_ganh_app/api_services/Imguser_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageraccountScreen extends StatefulWidget {
  const ManageraccountScreen({super.key});

  @override
  _ManageraccountScreen createState() => _ManageraccountScreen();
}

class _ManageraccountScreen extends State<ManageraccountScreen> {
  File? _image;
  final UserImageUploadService _uploadService = UserImageUploadService();
  final UserApiService _apiService = UserApiService();
  String _tenNguoiDung = 'Người dùng';
  String _userId = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      NguoiDung? user = await UserApiService().fetchUserDetails(storedUserId);
      if (user != null) {
        if (mounted) {
          setState(() {
            _tenNguoiDung = user.tenNguoiDung ?? 'Người dùng';
            _userId = storedUserId;
            _profileImageUrl = user.anhDaiDien;
          });
        }
      } else {
        print('User details not found.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      if (_userId.isNotEmpty) {
        try {
          bool success = await _uploadService.uploadImage(_image!, _userId);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ảnh đã được tải lên thành công!')),
              
            );
                   _loadUserDetails();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lỗi khi tải ảnh lên.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xảy ra lỗi: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy userId.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa chọn ảnh.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 90),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 110, 
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(41, 87, 35, 1),
                       border: Border.all(
                    color: const  Color.fromRGBO(41, 87, 35, 1), // Màu viền
                    width: 1.5, // Độ dày viền
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                  child: _image == null && _profileImageUrl == null
                      ? const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 50,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _tenNguoiDung, // Hiển thị tên người dùng
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(41, 87, 35, 1),
              ),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/hoso_icon.png"),
              title: const Text('Hồ sơ'),
              onTap: () {
                Navigator.pushNamed(context, '/ProfileScreen');
              },
            ),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/lienketthu_icon.png"),
              title: const Text('Liên kết thẻ'),
              onTap: () {
                Navigator.pushNamed(context, '/CardLinkScreen');
              },
            ),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/donhang_icon.png"),
              title: const Text('Đơn hàng'),
              onTap: () {
                Navigator.pushNamed(context, '/oder_screen');
              },
            ),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/caidat_icon.png"),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pushNamed(context, '/setting_screen');
              },
            ),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/trungtamhotro_icon.png"),
              title: const Text('Trung tâm hỗ trợ'),
              onTap: () {},
            ),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/baomat_icon.png"),
              title: const Text('Bảo mật'),
              onTap: () {
                Navigator.pushNamed(context, '/SecurityScreen');
              },
            ),
            Divider(thickness: 1, height: 1),
            ListTile(
              leading: Image.asset("lib/assets/dangxuat_icon.png"),
              title: const Text('Đăng xuất'),
              // Trong phần onTap của danh sách đăng xuất
              onTap: () async {
                // Xóa thông tin người dùng từ SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('userDisplayName');
                await prefs.remove('userEmail');
                await prefs.remove('userId');
                await prefs.remove('token');
                // Đăng xuất khỏi Google
                await GoogleSignIn().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) =>
                      false, // Xóa tất cả các route trước đó
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
