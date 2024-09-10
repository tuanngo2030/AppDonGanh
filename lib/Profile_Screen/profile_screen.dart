import 'dart:io';
import 'package:don_ganh_app/api_services/Imguser_api_service.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  File? _image;
  final UserImageUploadService _uploadService = UserImageUploadService();
  final UserApiService _apiService = UserApiService();
  String _tenNguoiDung = 'Người dùng';
  String _userId = '';
  String? _profileImageUrl;
  String _GioiTinh = 'Chưa xác định';
  String _ngaySinh = 'Chưa cập nhật';
  int _soDienThoai = 0;
  String _gmail = 'Chưa cập nhật';
  DiaChi _diaChi = DiaChi(
    tinhThanhPho: 'Chưa cập nhật',
    quanHuyen: 'Chưa cập nhật',
    phuongXa: 'Chưa cập nhật',
    duongThon: 'Chưa cập nhật',
  );

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
        setState(() {
          _tenNguoiDung = user.tenNguoiDung ?? 'Người dùng';
          _userId = storedUserId;
          _GioiTinh = user.GioiTinh ?? 'Chưa xác định';
          _ngaySinh = user.ngaySinh ?? 'Chưa cập nhật';
          _soDienThoai = user.soDienThoai ?? 0;
          _gmail = user.gmail ?? 'Chưa cập nhật';
          _profileImageUrl = user.anhDaiDien;
          _diaChi = user.diaChi ?? _diaChi;
        });
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
            // Cập nhật lại hình ảnh từ backend
            _loadUserDetails();
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
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/bottom');
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          'Hồ sơ',
          style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
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
              _tenNguoiDung,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(41, 87, 35, 1),
              ),
            ),
            SizedBox(height: 20),
            _buildProfileItem('Tên', _tenNguoiDung),
            _buildProfileItem('Giới tính', _GioiTinh),
            _buildProfileItem('Ngày sinh', _ngaySinh),
            _buildProfileItem('Điện thoại', _soDienThoai.toString()),
            _buildProfileItem('Email', _gmail),
            _buildProfileItem('Địa chỉ', _getDiaChiString()),
          ],
        ),
      ),
    );
  }

  String _getDiaChiString() {
    return '${_diaChi.tinhThanhPho}, ${_diaChi.quanHuyen}, ${_diaChi.phuongXa}, ${_diaChi.duongThon}';
  }

  Widget _buildProfileItem(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 150, // Đặt kích thước phù hợp với nhu cầu của bạn
        child: Text(
          value,
          overflow: TextOverflow.ellipsis, // Để cắt bỏ văn bản nếu nó dài
        ),
      ),
      onTap: () {
        if (title == 'Tên') {
          Navigator.pushNamed(context, '/ten');
        }
        if (title == 'Giới tính') {
          Navigator.pushNamed(context, '/gioitinh');
        }
        if (title == 'Ngày sinh') {
          Navigator.pushNamed(context, '/NgaySinh');
        }
        if (title == 'Điện thoại') {
          Navigator.pushNamed(context, '/sodienthoai');
        }
        if (title == 'Email') {
          Navigator.pushNamed(context, '/gmail');
        }
        if (title == 'Địa chỉ') {
          Navigator.pushNamed(context, '/diachiScreen');
        }
      },
    );
  }
}
