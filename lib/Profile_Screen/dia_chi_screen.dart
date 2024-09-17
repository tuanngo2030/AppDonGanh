import 'dart:convert';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DiaChiScreen extends StatefulWidget {
  const DiaChiScreen({super.key});

  @override
  State<DiaChiScreen> createState() => _DiaChiScreen();
}

class _DiaChiScreen extends State<DiaChiScreen> {
  String _userId = '';
  final TextEditingController _duongThonController = TextEditingController();

  List<String> _tinhThanhPhoList = [];
  List<String> _quanHuyenList = [];
  List<String> _phuongXaList = [];

  String? _selectedTinhThanhPho;
  String? _selectedQuanHuyen;
  String? _selectedPhuongXa;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchTinhThanhPho();
    _fetchQuanHuyen();
    _fetchPhuongXa();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      setState(() {
        _userId = storedUserId;
      });

      // Fetch user details including address
      NguoiDung? user = await UserApiService().fetchUserDetails(storedUserId);
      if (user != null) {
        setState(() {
          _selectedTinhThanhPho = user.diaChi?.tinhThanhPho;
          _selectedQuanHuyen = user.diaChi?.quanHuyen;
          _selectedPhuongXa = user.diaChi?.phuongXa;
          _duongThonController.text = user.diaChi?.duongThon ?? '';
        });
      } else {
        print('No address found for user.');
      }
    } else {
      print('User ID is not available.');
    }
  }

  Future<void> _fetchTinhThanhPho() async {
    try {
      final response =
          await http.get(Uri.parse('https://provinces.open-api.vn/api/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _tinhThanhPhoList =
              data.map((item) => item['name'] as String).toList();
        });
      } else {
        print('Failed to load provinces, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching provinces: $e');
    }
  }

  Future<void> _fetchQuanHuyen() async {
    try {
      final response =
          await http.get(Uri.parse('https://provinces.open-api.vn/api/d/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _quanHuyenList = data.map((item) => item['name'] as String).toList();
        });
      } else {
        print('Failed to load districts');
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> _fetchPhuongXa() async {
    try {
      final response =
          await http.get(Uri.parse('https://provinces.open-api.vn/api/w/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _phuongXaList = data.map((item) => item['name'] as String).toList();
        });
      } else {
        print('Failed to load wards');
      }
    } catch (e) {
      print('Error fetching wards: $e');
    }
  }

  Future<void> _updateAddress() async {
    if (_userId.isNotEmpty &&
        _selectedTinhThanhPho != null &&
        _selectedQuanHuyen != null &&
        _selectedPhuongXa != null &&
        _duongThonController.text.isNotEmpty) {
      DiaChi newAddress = DiaChi(
        tinhThanhPho: _selectedTinhThanhPho!,
        quanHuyen: _selectedQuanHuyen!,
        phuongXa: _selectedPhuongXa!,
        duongThon: _duongThonController.text,
      );

      try {
        bool success =
            await UserApiService().updateUserAddress(_userId, newAddress);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Địa chỉ đã được cập nhật thành công')),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật địa chỉ thất bại')),
          );
        }
      } catch (e) {
        print('Error updating address: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi cập nhật địa chỉ')),
        );
      }
    } else {
      print(
          'Missing required fields. UserID: $_userId, Tỉnh/Thành phố: $_selectedTinhThanhPho, Quận/Huyện: $_selectedQuanHuyen, Phường/Xã: $_selectedPhuongXa, Đường/Thôn: ${_duongThonController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật địa chỉ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                items: _tinhThanhPhoList,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTinhThanhPho = newValue;
                  });
                },
                selectedItem: _selectedTinhThanhPho,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                items: _quanHuyenList,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
                onChanged: (newValue) {
                  setState(() {
                    _selectedQuanHuyen = newValue;
                  });
                },
                selectedItem: _selectedQuanHuyen,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Quận/Huyện',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                items: _phuongXaList,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPhuongXa = newValue;
                  });
                },
                selectedItem: _selectedPhuongXa,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Phường/Xã',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _duongThonController,
                decoration: const InputDecoration(
                  labelText: 'Đường/Thôn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateAddress,
                  child: const Text('Cập nhật địa chỉ',
                   style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
