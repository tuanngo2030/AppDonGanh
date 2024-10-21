import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  TextEditingController _tinhThanhPhoController = TextEditingController();
  TextEditingController _quanHuyenController = TextEditingController();
  TextEditingController _phuongXaController = TextEditingController();
  LatLng? _selectedLocation;
  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      _duongThonController.text = widget.address!.duongThon!;
      _tenController.text = widget.address!.name!;
      _soDienThoaiController.text = widget.address!.soDienThoai!;
      _tinhThanhPhoController.text = widget.address!.tinhThanhPho!;
      _quanHuyenController.text = widget.address!.quanHuyen!;
      _phuongXaController.text = widget.address!.phuongXa!;
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
          style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1),fontWeight: FontWeight.bold ),
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

            // TextField cho Tỉnh/Thành Phố
            TextField(
              controller: _tinhThanhPhoController,
              decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
            ),
            const SizedBox(height: 10),

            // TextField cho Quận/Huyện
            TextField(
              controller: _quanHuyenController,
              decoration: const InputDecoration(labelText: 'Quận/Huyện'),
            ),
            const SizedBox(height: 10),

            // TextField cho Phường/Xã
            TextField(
              controller: _phuongXaController,
              decoration: const InputDecoration(labelText: 'Phường/Xã'),
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
                backgroundColor: Color.fromRGBO(41, 87, 35, 1), // Màu nền
                minimumSize: Size(double.infinity, 50),
                foregroundColor: Color.fromRGBO(255, 255, 255, 1),
              ),
              onPressed: () async {
                // Kiểm tra tất cả các trường có giá trị hay chưa
                if (_tenController.text.isEmpty ||
                    _soDienThoaiController.text.isEmpty ||
                    _duongThonController.text.isEmpty ||
                    _tinhThanhPhoController.text.isEmpty ||
                    _quanHuyenController.text.isEmpty ||
                    _phuongXaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng điền đầy đủ thông tin')),
                  );
                  return;
                }

                // Kiểm tra xem số điện thoại có đúng 10 chữ số hay không
                if (_soDienThoaiController.text.length != 10 ||
                    !_soDienThoaiController.text
                        .startsWith('0') || // Kiểm tra bắt đầu bằng số 0
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
                  tinhThanhPho: _tinhThanhPhoController.text,
                  quanHuyen: _quanHuyenController.text,
                  phuongXa: _phuongXaController.text,
                  duongThon: _duongThonController.text,
                  name: _tenController.text,
                  soDienThoai: _soDienThoaiController.text,
                );

                try {
                  if (widget.address == null) {
                    // Tạo địa chỉ mới
                    await DiaChiApiService()
                        .createDiaChi(widget.userId, newAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm địa chỉ thành công')),
                    );
                  } else {
                    // Cập nhật địa chỉ
                    await DiaChiApiService().updateDiaChi(
                        widget.userId, widget.address!.id!, newAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cập nhật địa chỉ thành công')),
                    );
                  }

                  // Trả về true để thông báo load lại danh sách
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
