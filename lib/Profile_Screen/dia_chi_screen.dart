import 'package:don_ganh_app/Profile_Screen/AddressScreen.dart';
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
      _isLoading = true;
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
      _isLoading = false;
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddressFormScreen(userId: _userId),
              ),
            ).then((result) {
              if (result == true) {
                _fetchAddresses(); // Tải lại danh sách địa chỉ
              }
            });
          },
        ),
      ],
      title: const Text(
        'Danh sách địa chỉ',
        style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1),fontWeight: FontWeight.bold),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressFormScreen(
                                    address: address, userId: _userId),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _fetchAddresses(); // Tải lại danh sách địa chỉ
                              }
                            });
                          },
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