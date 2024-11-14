import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/address_api.dart'; // Import service API
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  TextEditingController _kinhDoController = TextEditingController(); // Kinh độ
  TextEditingController _viDoController = TextEditingController(); // Vĩ độ

  String? _selectedTinhThanhPho; // Tỉnh/Thành phố
  String? _selectedQuanHuyen; // Quận/Huyện
  String? _selectedPhuongXa; // Phường/Xã

  List<String> _tinhThanhPhoList = [];
  List<String> _quanHuyenList = [];
  List<String> _phuongXaList = [];

  DcApiService _dcApiService = DcApiService();
  LatLng _currentLocation =
      LatLng(21.035965, 105.834747); // Default location: Hanoi
  MapController _mapController = MapController();
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
      _kinhDoController.text = widget.address!.kinhdo ?? '';
      _viDoController.text = widget.address!.vido ?? '';
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

  // Mở màn hình bản đồ
  void _openMap() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: _currentLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentLocation = result;
        _kinhDoController.text = result.latitude.toString();
        _viDoController.text = result.longitude.toString();
      });
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
            // Hiển thị Kinh độ và Vĩ độ
            TextField(
              controller: _kinhDoController,
              decoration: InputDecoration(labelText: 'Kinh độ'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _viDoController,
              decoration: InputDecoration(labelText: 'Vĩ độ'),
            ),
            const SizedBox(height: 10),

            // Nút mở bản đồ
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                minimumSize: Size(double.infinity, 50),
                foregroundColor: Color.fromRGBO(255, 255, 255, 1),
              ),
              onPressed: _openMap,
              child: Text('Chọn vị trí từ bản đồ'),
            ),
            const SizedBox(height: 10),
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
                  kinhdo:
                      _kinhDoController.text, // Lưu trực tiếp chuỗi nhập vào
                  vido: _viDoController.text, // Lưu trực tiếp chuỗi nhập vào
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

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapScreen({Key? key, required this.initialLocation}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _currentLocation;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _mapController = MapController();
  }

  // Hàm lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ vị trí
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Nếu không bật dịch vụ vị trí, yêu cầu người dùng bật
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Nếu quyền truy cập bị từ chối
        return;
      }
    }

    // Lấy vị trí hiện tại
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      // Cập nhật lại bản đồ đến vị trí mới
      _mapController.move(_currentLocation, 13.0);
    });
  }

  // Show confirmation dialog
  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận vị trí'),
          content: Text(
              'Bạn có chắc chắn muốn chọn vị trí này?\kinh độ: ${_currentLocation.latitude}, vĩ độ: ${_currentLocation.longitude}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without doing anything
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context, _currentLocation); // Return the selected location
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn vị trí'),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            setState(() {
              _currentLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation,
                width: 80.0,
                height: 80.0,
                child: Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation == widget.initialLocation) {
            _getCurrentLocation();
          } else {
            _showConfirmationDialog();
          }
        },
        child: Icon(
          _currentLocation == widget.initialLocation
              ? Icons.my_location 
              : Icons.check, 
        ),
      ),
    );
  }
}
