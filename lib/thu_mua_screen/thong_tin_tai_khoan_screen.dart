import 'dart:convert';
import 'package:don_ganh_app/thu_mua_screen/update_dia_chi_ho_kinh_doanh_screen.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/yeu_cau_dang_ky_thu_mua_api_service.dart';
import 'package:intl/intl.dart';

class ThongTinTaiKhoanScreen extends StatefulWidget {
  const ThongTinTaiKhoanScreen({super.key});

  @override
  State<ThongTinTaiKhoanScreen> createState() => _ThongTinTaiKhoanScreenState();
}

class _ThongTinTaiKhoanScreenState extends State<ThongTinTaiKhoanScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }

  Future<void> _fetchUserData() async {
    const String userId =
        "6725a59421c28ad87ab2b22f"; // Replace with dynamic userId if needed
    try {
      final response =
          await YeuCauDangKyService().getYeuCauDangKyDiaChiByUserId(userId);
      setState(() {
        userData = response;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    }
  }

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildAddressRow({
  required IconData icon,
  required String label,
  required String address,
  required VoidCallback onUpdate,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onUpdate,
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Thông Tin Tài Khoản'),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : userData == null
            ? const Center(child: Text("Không có dữ liệu"))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          icon: Icons.person,
                          label: "Họ tên",
                          value: userData!['diaChi']['Name'],
                        ),
                        _buildInfoRow(
                          icon: Icons.phone,
                          label: "Số điện thoại",
                          value: userData!['diaChi']['SoDienThoai'],
                        ),
                        _buildAddressRow(
                          icon: Icons.location_on,
                          label: "Địa chỉ",
                          address:
                              "${userData!['diaChi']['duongThon']}, ${userData!['diaChi']['phuongXa']}, ${userData!['diaChi']['quanHuyen']}, ${userData!['diaChi']['tinhThanhPho']}",
                          onUpdate: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateDiaChiHoKinhDoanhScreen(
                                  diaChi: userData!['diaChi'],
                                  yeucaudangkyId: userData!['_id'],
                                  hoten: userData!['diaChi']['Name'],
                                  sodienthoai: userData!['diaChi']['SoDienThoai'],
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                // Gọi hàm để tải lại dữ liệu
                                _fetchUserData();
                              }
                            });
                          },
                        ),
                        _buildInfoRow(
                          icon: Icons.notes,
                          label: "Ghi chú",
                          value: userData!['ghiChu'],
                        ),
                        _buildInfoRow(
                          icon: Icons.delivery_dining,
                          label: "Hình thức giao hàng",
                          value: userData!['hinhthucgiaohang'],
                        ),
                        _buildInfoRow(
                          icon: Icons.info,
                          label: "Trạng thái",
                          value: userData!['trangThai'],
                        ),
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: "Ngày tạo",
                          value: _formatDate(userData!['ngayTao']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
  );
}
}
