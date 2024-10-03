import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String _userId = '';
  List<diaChiList> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      setState(() {
        _userId = storedUserId;
      });
      _fetchAddresses();
    } else {
      print('User ID not found');
    }
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null && storedUserId.isNotEmpty) {
      List<diaChiList> addresses =
          await DiaChiApiService().getDiaChiByUserId(storedUserId);

      setState(() {
        _addresses = addresses;
      });
      print('Fetched addresses: $_addresses');
    } else {
      print('User ID not found in SharedPreferences');
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  Future<void> _deleteAddress(String diaChiId) async {
    bool success = await DiaChiApiService().deleteDiaChi(_userId, diaChiId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ đã được xóa thành công')),
      );
      _fetchAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa địa chỉ thất bại')),
      );
    }
  }

  void _showAddressDialog({diaChiList? address}) async {
    TextEditingController _duongThonController =
        TextEditingController(text: address?.duongThon ?? '');
    TextEditingController _tenController =
        TextEditingController(text: address?.name ?? '');
    TextEditingController _soDienThoaiController =
        TextEditingController(text: address?.soDienThoai ?? '');

    String? _selectedTinhThanhPho = address?.tinhThanhPho;
    String? _selectedQuanHuyen = address?.quanHuyen;
    String? _selectedPhuongXa = address?.phuongXa;

    List<String> _tinhThanhPhoList = await dcApiService().getProvinces();
    List<String> _quanHuyenList =
        await dcApiService().getDistricts(_selectedTinhThanhPho ?? '');
    List<String> _phuongXaList =
        await dcApiService().getWards(_selectedQuanHuyen ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _soDienThoaiController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),

              // DropdownSearch for Tỉnh/Thành Phố
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
                decoration: const InputDecoration(labelText: 'Đường/Thôn'),
                controller: _duongThonController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
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

              diaChiList newAddress = diaChiList(
                tinhThanhPho: _selectedTinhThanhPho ?? '',
                quanHuyen: _selectedQuanHuyen ?? '',
                phuongXa: _selectedPhuongXa ?? '',
                duongThon: _duongThonController.text,
                name: _tenController.text,
                soDienThoai: _soDienThoaiController.text,
              );

              if (address == null) {
                await DiaChiApiService().createDiaChi(_userId, newAddress);
              } else {
                await DiaChiApiService()
                    .updateDiaChi(_userId, address.id!, newAddress);
              }

              Navigator.pop(context);
              _fetchAddresses();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddressDialog(),
          ),
        ],
        title: const Text(
          'Danh sách địa chỉ',
          style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? const Center(child: Text('Không có địa chỉ nào.'))
              : ListView.builder(
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return ListTile(
                      title: Text(
                        'Họ và tên: ${address.name} \nSố điện thoại: ${address.soDienThoai}',
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                      subtitle: Text(
                        'Địa chỉ: ${address.duongThon}, ${address.phuongXa}, ${address.quanHuyen}, ${address.tinhThanhPho}',
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showAddressDialog(address: address),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAddress(address.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
