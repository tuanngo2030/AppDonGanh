import 'dart:io';
import 'package:flutter/material.dart';
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
  String _tenNguoiDung = 'Người dùng';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tenNguoiDung = prefs.getString('tenNguoiDung') ?? 'Người dùng';
    });
    print('Tên người dùng từ SharedPreferences: $_tenNguoiDung');
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        bool success = await _uploadService.uploadImage(_image!);

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
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
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
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/lienketthu_icon.png"),
              title: Text('Liên kết thẻ'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/donhang_icon.png"),
              title: Text('Đơn hàng'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/caidat_icon.png"),
              title: Text('Cài đặt'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/trungtamhotro_icon.png"),
              title: Text('Trung tâm hỗ trợ'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/baomat_icon.png"),
              title: Text('Bảo mật'),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset("lib/assets/dangxuat_icon.png"),
              title: Text('Đăng xuất'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
