import 'dart:io';
import 'package:don_ganh_app/api_services/Imguser_api_service.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  File? _image;
  final UserImageUploadService _uploadService = UserImageUploadService();
  final UserApiService _apiService = UserApiService();
  final DiaChiApiService _diaChiApiService = DiaChiApiService();
  String _tenNguoiDung = 'Người dùng';
  String _userId = '';
  String? _profileImageUrl;
  String _gioiTinh = 'Chưa xác định';
  String _ngaySinh = 'Chưa cập nhật';
  String _soDienThoai = 'Chưa cập nhật';
  String _gmail = 'Chưa cập nhật';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');
     String? token = prefs.getString('token');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      NguoiDung? user = await _apiService.fetchUserDetails(storedUserId, token!);
      if (user != null) {
        if (mounted) {
          // Kiểm tra mounted trước khi gọi setState
          setState(() {
            _tenNguoiDung = user.tenNguoiDung ?? 'Người dùng';
            _userId = storedUserId;
            _gioiTinh = user.GioiTinh ?? 'Chưa xác định';
            _ngaySinh = user.ngaySinh ?? 'Chưa cập nhật';
            _soDienThoai = user.soDienThoai ?? 'Chưa cập nhật';
            _gmail = user.gmail ?? 'Chưa cập nhật';
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

 bool _isDisposed = false;

@override
void dispose() {
  _isDisposed = true;
  super.dispose();
}

Future<void> _pickImage() async {
  final XFile? pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);

  if (_isDisposed) return;

  if (pickedFile != null) {
    if (mounted) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    if (_userId.isNotEmpty) {
      try {
        bool success = await _uploadService.uploadImage(_image!, _userId);

        if (!_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  success ? 'Ảnh đã được tải lên thành công!' : 'Lỗi khi tải ảnh lên.'),
            ),
          );
        }

        if (success) {
          if (!_isDisposed) {
            _loadUserDetails();
          }
        }
      } catch (e) {
        if (!_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xảy ra lỗi: $e')),
          );
        }
      }
    } else {
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy userId.')),
        );
      }
    }
  } else {
    if (!_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa chọn ảnh.')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: const Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: const Text(
          'Hồ sơ',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
              _tenNguoiDung,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(41, 87, 35, 1),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, height: 1),
            _buildProfileItem('Tên', _tenNguoiDung),
            const Divider(thickness: 1, height: 1),
            _buildProfileItem('Giới tính', _gioiTinh),
            const Divider(thickness: 1, height: 1),
            _buildProfileItem('Ngày sinh', _ngaySinh),
            const Divider(thickness: 1, height: 1),
            _buildProfileItem('Điện thoại', _soDienThoai),
            const Divider(thickness: 1, height: 1),
            // _buildProfileItem('Email', _gmail),
            // const Divider(thickness: 1, height: 1),
            _buildDiaChiItems(),
            const Divider(thickness: 1, height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaChiItems() {
    return _buildProfileItem('Địa chỉ', 'Danh sách địa chỉ');
  }

  Widget _buildProfileItem(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 120, // Đặt kích thước phù hợp với nhu cầu của bạn
        child: Text(
          value,
          overflow: TextOverflow.ellipsis, // Để cắt bỏ văn bản nếu nó dài
        ),
      ),
      onTap: () async {
        if (title == 'Tên') {
          await Navigator.pushNamed(context, '/ten');
        }
        if (title == 'Giới tính') {
          await Navigator.pushNamed(context, '/gioitinh');
        }
        if (title == 'Ngày sinh') {
          await Navigator.pushNamed(context, '/NgaySinh');
        }
        if (title == 'Điện thoại') {
          await Navigator.pushNamed(context, '/sodienthoai');
        }
        if (title == 'Email') {
          await Navigator.pushNamed(context, '/gmail');
        }
        if (title == 'Địa chỉ') {
          await Navigator.pushNamed(context, '/diachiScreen');
        }
        if (mounted) {
          // Kiểm tra mounted trước khi gọi _loadUserDetails()
          _loadUserDetails();
        }
      },
    );
  }

  // @override
  // void dispose() {
  //   // Hủy bỏ tất cả các tác vụ cần thiết ở đây nếu có
  //   super.dispose();
  // }
}
