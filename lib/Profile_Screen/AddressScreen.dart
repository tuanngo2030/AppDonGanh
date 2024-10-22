import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/address_api.dart'; // Import service API
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddressFormScreen extends StatefulWidget {
  final diaChiList? address;
  final String userId;

  const AddressFormScreen({Key? key, this.address, required this.userId})
      : super(key: key);

  @override
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  TextEditingController _duongThonController = TextEditingController();
  TextEditingController _tenController = TextEditingController();
  TextEditingController _soDienThoaiController = TextEditingController();

  String? _selectedTinhThanhPho; // Tỉnh/Thành phố
  String? _selectedQuanHuyen; // Quận/Huyện
  String? _selectedPhuongXa; // Phường/Xã

  List<String> _tinhThanhPhoList = [];
  List<String> _quanHuyenList = [];
  List<String> _phuongXaList = [];

  DcApiService _dcApiService = DcApiService();

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      _duongThonController.text = widget.address!.duongThon!;
      _tenController.text = widget.address!.name!;
      _soDienThoaiController.text = widget.address!.soDienThoai!;
      _selectedTinhThanhPho = widget.address!.tinhThanhPho;
      _selectedQuanHuyen = widget.address!.quanHuyen;
      _selectedPhuongXa = widget.address!.phuongXa;
    }

    _loadTinhThanhPho();
    _loadQuanHuyen();
    _loadPhuongXa();
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

  Future<void> _loadQuanHuyen() async {
    try {
      final districts = await _dcApiService.getQuanHuyen();
      setState(() {
        _quanHuyenList = districts;
      });
    } catch (e) {
      print('Error loading districts: $e');
    }
  }

  Future<void> _loadPhuongXa() async {
    try {
      final wards = await _dcApiService.getPhuongXa();
      setState(() {
        _phuongXaList = wards;
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
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: Text(
          widget.address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ',
          style: TextStyle(
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
            TextField(
              controller: _tenController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soDienThoaiController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            // Dropdown cho Tỉnh/Thành phố
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

            // Dropdown cho Quận/Huyện
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

            // Dropdown cho Phường/Xã
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

            // TextField cho Đường/Thôn
            TextField(
              controller: _duongThonController,
              decoration: const InputDecoration(labelText: 'Đường/Thôn'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                minimumSize: Size(double.infinity, 50),
                foregroundColor: Color.fromRGBO(255, 255, 255, 1),
              ),
              onPressed: () async {
                // Kiểm tra tất cả các trường có giá trị hay chưa
                if (_tenController.text.isEmpty ||
                    _soDienThoaiController.text.isEmpty ||
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

                // Kiểm tra số điện thoại
                if (_soDienThoaiController.text.length != 10 ||
                    !_soDienThoaiController.text.startsWith('0') ||
                    !_soDienThoaiController.text
                        .contains(RegExp(r'^[0-9]+$'))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Số điện thoại phải có 10 chữ số và bắt đầu bằng 0')),
                  );
                  return;
                }

                diaChiList newAddress = diaChiList(
                  tinhThanhPho: _selectedTinhThanhPho,
                  quanHuyen: _selectedQuanHuyen,
                  phuongXa: _selectedPhuongXa,
                  duongThon: _duongThonController.text,
                  name: _tenController.text,
                  soDienThoai: _soDienThoaiController.text,
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
