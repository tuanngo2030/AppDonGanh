import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/yeu_cau_dang_ky_thu_mua_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:flutter/material.dart';

class UpdateDiaChiHoKinhDoanhScreen extends StatefulWidget {
  final Map<String, dynamic> diaChi;
  final String yeucaudangkyId;
  final String hoten;
  final String sodienthoai;
  const UpdateDiaChiHoKinhDoanhScreen(
      {super.key,
      required this.diaChi,
      required this.yeucaudangkyId,
      required this.hoten,
      required this.sodienthoai});

  @override
  State<UpdateDiaChiHoKinhDoanhScreen> createState() =>
      _UpdateDiaChiHoKinhDoanhScreenState();
}

class _UpdateDiaChiHoKinhDoanhScreenState
    extends State<UpdateDiaChiHoKinhDoanhScreen> {
  final TextEditingController duongThonController = TextEditingController();
  List<dynamic> _tinhThanhPhoList = [];
  List<dynamic> _quanHuyenList = [];
  List<dynamic> _phuongXaList = [];

  String? _selectedTinhThanhPhoCode; // Lưu code của tỉnh/thành phố
  String? _selectedTinhThanhPho; // Lưu name của tỉnh/thành phố

  String? _selectedQuanHuyenCode; // Lưu code của quận/huyện
  String? _selectedQuanHuyen; // Lưu name của quận/huyện

  String? _selectedPhuongXaCode; // Lưu code của phường/xã
  String? _selectedPhuongXa; // Lưu name của phường/xã

  String? duongThon;

  final DcApiService _dcApiService = DcApiService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

 Future<void> _updateDiaChi() async {
  if (_selectedTinhThanhPho == null ||
      _selectedQuanHuyen == null ||
      _selectedPhuongXa == null ||
      duongThonController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin địa chỉ")),
    );
    return;
  }

  // Show confirmation dialog
  bool? isConfirmed = await _showConfirmationDialog();

  if (isConfirmed == true) {
    // Assign `duongThon` from the controller
    String duongThon = duongThonController.text;

    // Create the new address object
    diaChiList newAddress = diaChiList(
      tinhThanhPho: _selectedTinhThanhPho!,
      quanHuyen: _selectedQuanHuyen!,
      phuongXa: _selectedPhuongXa!,
      duongThon: duongThon,
      name: widget.hoten,
      soDienThoai: widget.sodienthoai,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await YeuCauDangKyService().updateDiaChiHoKinhDoanh(
        yeucaudangkyId: widget.yeucaudangkyId,
        diaChiMoi: newAddress,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Cập nhật thành công")),
      );

      Navigator.pop(context, true); // Quay lại màn hình trước
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Confirmation Dialog Method
Future<bool?> _showConfirmationDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Xác nhận cập nhật địa chỉ'),
        content: const Text('Bạn có chắc chắn muốn cập nhật địa chỉ không?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User cancels
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms
            },
            child: const Text('Xác nhận'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Lấy địa chỉ cũ
    String diaChiCuu =
        "${widget.diaChi['duongThon']}, ${widget.diaChi['phuongXa']}, ${widget.diaChi['quanHuyen']}, ${widget.diaChi['tinhThanhPho']}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập Nhật Địa Chỉ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ cũ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                diaChiCuu,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: DropdownButtonFormField<String>(
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
                        _loadQuanHuyen(
                            value!); // Gọi hàm để tải danh sách quận/huyện
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
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
                        _selectedQuanHuyen = _quanHuyenList.firstWhere(
                            (district) =>
                                district['code'].toString() == value)['name'];
                        _loadPhuongXa(
                            value!); // Gọi hàm để tải danh sách phường/xã
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: DropdownButtonFormField<String>(
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
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: duongThonController,
                    decoration: InputDecoration(
                      labelText: 'Đường/Thôn xóm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateDiaChi,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Cập nhật địa chỉ"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
