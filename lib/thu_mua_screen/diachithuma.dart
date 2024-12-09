import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/address_api.dart'; // Import service API
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Diachithuma extends StatefulWidget {
  final diaChiList? address;
  final String userId;

  const Diachithuma({super.key, this.address, required this.userId});

  @override
  _DiachithumaState createState() => _DiachithumaState();
}

class _DiachithumaState extends State<Diachithuma> {
  final TextEditingController _duongThonController = TextEditingController();
  final DcApiService _dcApiService = DcApiService();

  List<dynamic> _tinhThanhPhoList = [];
  List<dynamic> _quanHuyenList = [];
  List<dynamic> _phuongXaList = [];

  String? _selectedTinhThanhPhoCode; // Lưu code của tỉnh/thành phố
  String? _selectedTinhThanhPho; // Lưu name của tỉnh/thành phố

  String? _selectedQuanHuyenCode; // Lưu code của quận/huyện
  String? _selectedQuanHuyen; // Lưu name của quận/huyện

  String? _selectedPhuongXaCode; // Lưu code của phường/xã
  String? _selectedPhuongXa; // Lưu name của phường/xã

  LatLng _currentLocation =
      const LatLng(21.035965, 105.834747); // Default location: Hanoi
  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      _duongThonController.text = widget.address!.duongThon!;
      _selectedTinhThanhPho = widget.address!.tinhThanhPho;
      _selectedQuanHuyen = widget.address!.quanHuyen;
      _selectedPhuongXa = widget.address!.phuongXa;
    }
    _loadTinhThanhPho();
  }

  Future<void> _loadTinhThanhPho() async {
    try {
      final provinces = await _dcApiService.getTinhThanhPho();
      setState(() {
        _tinhThanhPhoList = provinces;
      });
    } catch (e) {
      print('Error loading provinces: $e');
    }
  }

  Future<void> _loadQuanHuyen(String cityCode) async {
    try {
      final districts = await _dcApiService.getQuanHuyen(cityCode);
      setState(() {
        _quanHuyenList = districts;
        _phuongXaList = [];
        _selectedQuanHuyen = null;
        _selectedPhuongXa = null;
      });
    } catch (e) {
      print('Error loading districts: $e');
    }
  }

  Future<void> _loadPhuongXa(String districtCode) async {
    try {
      final wards = await _dcApiService.getPhuongXa(districtCode);
      setState(() {
        _phuongXaList = wards;
        _selectedPhuongXa = null;
      });
    } catch (e) {
      print('Error loading wards: $e');
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
              Navigator.pop(context);
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: const Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          widget.address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ',
          style: const TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedTinhThanhPhoCode,
              decoration: InputDecoration(
                labelText: "Chọn Tỉnh/Thành phố",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _tinhThanhPhoList.map((province) {
                return DropdownMenuItem<String>(
                  value: province['code'].toString(), // Dùng code để chọn
                  child: Text(province['name']), // Hiển thị name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTinhThanhPhoCode = value; // Lưu code
                  _selectedTinhThanhPho = _tinhThanhPhoList.firstWhere(
                      (province) =>
                          province['code'].toString() == value)['name'];
                  _loadQuanHuyen(value!); // Gọi hàm để tải danh sách quận/huyện
                });
              },
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedQuanHuyenCode,
              decoration: InputDecoration(
                labelText: "Chọn Quận/Huyện",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _quanHuyenList.map((district) {
                return DropdownMenuItem<String>(
                  value: district['code'].toString(), // Dùng code để chọn
                  child: Text(district['name']), // Hiển thị name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuanHuyenCode = value; // Lưu code
                  _selectedQuanHuyen = _quanHuyenList.firstWhere((district) =>
                      district['code'].toString() == value)['name'];
                  _loadPhuongXa(value!); // Gọi hàm để tải danh sách phường/xã
                });
              },
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedPhuongXaCode,
              decoration: InputDecoration(
                labelText: "Chọn Phường/Xã",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _phuongXaList.map((ward) {
                return DropdownMenuItem<String>(
                  value: ward['code'].toString(), // Dùng code để chọn
                  child: Text(ward['name']), // Hiển thị name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPhuongXaCode = value; // Lưu code
                  _selectedPhuongXa = _phuongXaList.firstWhere(
                      (ward) => ward['code'].toString() == value)['name'];
                });
              },
            ),

            const SizedBox(height: 30),

            // TextField cho Đường/Thôn
            TextField(
              maxLength: 100,
              controller: _duongThonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Đường/thôn',
                contentPadding: const EdgeInsets.all(16),
                counter: Text(
                  '${_duongThonController.text.length}/100', // Hiển thị số ký tự hiện tại
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
      
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(41, 87, 35, 1),
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
              ),
              onPressed: () async {
                // Kiểm tra tất cả các trường có giá trị hay chưa
                if (
                   _duongThonController.text.isEmpty ||
                    _selectedTinhThanhPho == null ||
                    _selectedQuanHuyen == null ||
                    _selectedPhuongXa == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng điền đầy đủ thông tin')),
                  );
                  return;
                }

      
                diaChiList newAddress = diaChiList(
                  tinhThanhPho: _selectedTinhThanhPho,
                  quanHuyen: _selectedQuanHuyen,
                  phuongXa: _selectedPhuongXa,
                  duongThon: _duongThonController.text,
                );

                try {
                  if (widget.address == null) {
                    await DiaChiApiService()
                        .createDiaChi(widget.userId, newAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm địa chỉ thành công')),
                    );
                  } else {
                    await DiaChiApiService().updateDiaChi(
                        widget.userId, widget.address!.id!, newAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cập nhật địa chỉ thành công')),
                    );
                  }

                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Có lỗi xảy ra: $e')),
                  );
                }
              },
              child: Text(
                  widget.address == null ? 'Thêm địa chỉ' : 'Cập nhật địa chỉ'),
            ),
          ],
        ),
      ),
    );
  }
}

