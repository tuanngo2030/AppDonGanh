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
              SnackBar(content: Text('Ảnh đã được tải lên thành công!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi tải ảnh lên.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xảy ra lỗi: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy userId.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn chưa chọn ảnh.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 90),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                child: _image == null && _profileImageUrl == null
                    ? Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 50,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _tenNguoiDung, // Hiển thị tên người dùng
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(41, 87, 35, 1),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Image.asset("lib/assets/hoso_icon.png"),
              title: Text('Hồ sơ'),
              onTap: () {
                Navigator.pushNamed(context, '/ProfileScreen');
              },
            ),
            ListTile(
              leading: Image.asset("lib/assets/lienketthu_icon.png"),
              title: Text('Liên kết thẻ'),
              onTap: () {
                Navigator.pushNamed(context, '/CardLinkScreen');
              },
            ),
            ListTile(
              leading: Image.asset("lib/assets/donhang_icon.png"),
              title: Text('Đơn hàng'),
              onTap: () {
                Navigator.pushNamed(context, '/oder_screen');
              },
            ),
            ListTile(
              leading: Image.asset("lib/assets/caidat_icon.png"),
              title: Text('Cài đặt'),
              onTap: () {
                Navigator.pushNamed(context, '/setting_screen');
              },
            ),
            ListTile(
              leading: Image.asset("lib/assets/trungtamhotro_icon.png"),
              title: Text('Trung tâm hỗ trợ'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/baomat_icon.png"),
              title: Text('Bảo mật'),
              onTap: () {
                Navigator.pushNamed(context, '/SecurityScreen');
              },
            ),
            ListTile(
              leading: Image.asset("lib/assets/dangxuat_icon.png"),
              title: Text('Đăng xuất'),
              // Trong phần onTap của danh sách đăng xuất
              onTap: () async {
                // Xóa thông tin người dùng từ SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('userDisplayName');
                await prefs.remove('userEmail');
                await prefs.remove('userId');
                await GoogleSignIn().signOut();
                // Điều hướng về màn hình đăng nhập
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
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
