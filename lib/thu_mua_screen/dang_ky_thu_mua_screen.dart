import 'dart:io';

import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/yeu_cau_dang_ky_thu_mua_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DangKyThuMuaScreen extends StatefulWidget {
  const DangKyThuMuaScreen({super.key});

  @override
  State<DangKyThuMuaScreen> createState() => _DangKyThuMuaScreenState();
}

class _DangKyThuMuaScreenState extends State<DangKyThuMuaScreen> {
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController duongThonController = TextEditingController();
  final TextEditingController soluongLoaiController = TextEditingController();
  final TextEditingController soluongSanPhamController =
      TextEditingController();
  TextEditingController maSoThueController = TextEditingController();
  List<dynamic> _tinhThanhPhoList = [];
  List<dynamic> _quanHuyenList = [];
  List<dynamic> _phuongXaList = [];

  String? _selectedTinhThanhPhoCode; // Lưu code của tỉnh/thành phố
  String? _selectedTinhThanhPho; // Lưu name của tỉnh/thành phố

  String? _selectedQuanHuyenCode; // Lưu code của quận/huyện
  String? _selectedQuanHuyen; // Lưu name của quận/huyện

  String? _selectedPhuongXaCode; // Lưu code của phường/xã
  String? _selectedPhuongXa; // Lưu name của phường/xã

  String groupValueRequest = "tugiao";
  // String? selectedTinh = '';
  // String? selectedQuan = '';
  // String? selectedPhuong = '';
  String? hoTen;
  String? soDienThoai;
  String? duongThon;
  String? userId;
  bool isSucces = false;

  File? _image;

  final _yeuCauDangKyService = YeuCauDangKyService();
  final DcApiService _dcApiService = DcApiService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTinhThanhPho();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Lưu đường dẫn hình ảnh
      });
    }
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

  Future<void> _createYeuCauDangKy() async {
    hoTen = hoTenController.text;
    soDienThoai = soDienThoaiController.text;
    duongThon = duongThonController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (hoTenController.text.isEmpty ||
        soDienThoaiController.text.isEmpty ||
        soluongLoaiController.text.isEmpty ||
        soluongSanPhamController.text.isEmpty ||
        maSoThueController.text.isEmpty ||
        _image == null ||
        // (selectedTinh ?? '').isEmpty || // Đảm bảo selectedTinh không phải null
        // (selectedQuan ?? '').isEmpty || // Đảm bảo selectedQuan không phải null
        // (selectedPhuong ?? '').isEmpty || // Đảm bảo selectedPhuong không phải null

        duongThonController.text.isEmpty) {
      _showSnackbar("Vui lòng điền đầy đủ thông tin.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    diaChiList newAddress = diaChiList(
      tinhThanhPho: _selectedTinhThanhPho,
      quanHuyen: _selectedQuanHuyen,
      phuongXa: _selectedPhuongXa,
      duongThon: duongThon!,
      name: hoTen,
      soDienThoai: soDienThoai,
    );

    try {
      final response = await _yeuCauDangKyService.createYeuCauDangKy(
        maSoThue: maSoThueController.text,
        file: _image,
        userId: userId!, // Replace with actual userId
        gmail: emailController.text,
        ghiChu: hoTenController.text,
        soluongloaisanpham: int.parse(soluongLoaiController.text),
        soluongsanpham: int.parse(soluongSanPhamController.text),
        diaChiMoi: newAddress,
        hinhthucgiaohang: groupValueRequest,
      );

      if (response.isNotEmpty) {
        _showSnackbar("Đăng ký thành công!");
        maSoThueController.clear();
        // Optionally reset form
        hoTenController.clear();
        soDienThoaiController.clear();
        emailController.clear();
        duongThonController.clear();
        soluongLoaiController.clear();
        soluongSanPhamController.clear();
        setState(() {
          isSucces = true;
          _selectedTinhThanhPho = "";
          _selectedQuanHuyen = "";
          _selectedPhuongXa = "";
          groupValueRequest = "Đòn gánh tới lấy";
          _image = null;
        });
      }
    } catch (error) {
      _showSnackbar("Có lỗi xảy ra: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
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
        title: const Text(
          'Đăng ký hộ kinh doanh',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (isSucces == true) ...[
                susccesDK(),
              ] else ...[
                _buildForm(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin khách hàng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          '*Những thông tin ở đây là thông tin mặc định của quý khách và những thay đổi ở đây sẽ không được lưu.',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: maSoThueController,
          decoration: InputDecoration(
            labelText: 'Mã số thuế',
            labelStyle: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
            ),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Giấy chứng nhận hộ kinh doanh',
                style: TextStyle(
                    color: Colors.black, // Màu chữ chính
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red, // Màu đỏ cho dấu sao
                  fontSize: 16, // Kích thước chữ
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 170, // Chiều cao của Container
            width: double.infinity, // Chiều rộng toàn màn hình
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(41, 87, 35, 1)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200], // Màu nền của Container
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Bo góc cho hình ảnh
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(
          height: 30,
        ),

        Row(
          children: [
            Expanded(
              flex: 6,
              child: TextField(
                maxLength: 30,
                controller: hoTenController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 4,
              child: TextField(
                maxLength: 10,
                controller: soDienThoaiController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
            ),
          ),
        ),

        const SizedBox(height: 25),
        const Text(
          'Địa chỉ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 15),

        // Address Dropdowns
        Row(
          children: [
            Expanded(
              flex: 6,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedTinhThanhPhoCode,
                decoration: InputDecoration(
                  labelText: "Chọn Tỉnh/Thành phố",
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
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
                    _selectedTinhThanhPhoCode = value;
                    _selectedTinhThanhPho = _tinhThanhPhoList.firstWhere(
                        (province) =>
                            province['code'].toString() == value)['name'];
                    _quanHuyenList = []; // Đặt lại danh sách quận/huyện
                    _phuongXaList = []; // Đặt lại danh sách phường/xã
                    _selectedQuanHuyenCode =
                        null; // Đặt lại giá trị được chọn cho quận/huyện
                    _selectedPhuongXaCode =
                        null; // Đặt lại giá trị được chọn cho phường/xã
                    if (value != null) {
                      _loadQuanHuyen(value); // Tải danh sách quận/huyện
                    }
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
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
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
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
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
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
        const Text(
          'Thông tin sản phẩm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 20),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mô tả",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Gõ vào đây",
                      border: InputBorder.none,
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.bottomRight,
                  //   child: TextButton.icon(
                  //     onPressed: () {
                  //       // Add your image picker functionality here
                  //     },
                  //     icon: const Icon(Icons.image,
                  //         color: Color.fromRGBO(41, 87, 35, 1)),
                  //     label: const Text(
                  //       "Thêm ảnh",
                  //       style: TextStyle(
                  //           color: Color.fromRGBO(41, 87, 35, 1)),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 6,
              child: TextField(
                controller: soluongLoaiController,
                keyboardType: TextInputType.number, // Hiển thị bàn phím số
                decoration: InputDecoration(
                  labelText: 'Số lượng loại sản phẩm(Dự kiến)',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 4,
              child: TextField(
                controller: soluongSanPhamController,
                keyboardType: TextInputType.number, // Hiển thị bàn phím số
                decoration: InputDecoration(
                  labelText: 'Số lượng sản phẩm(Dự kiến)',
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(41, 87, 35, 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(41, 87, 35, 1)),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        // const Text(
        //   "Hình thức giao hàng",
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        // ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       flex: 1,
        //       child: Container(
        //         child: Row(
        //           children: [
        //             Radio<String>(
        //               activeColor: const Color.fromRGBO(59, 99, 53, 1),
        //               value: "tugiao",
        //               groupValue: groupValueRequest,
        //               onChanged: (value) {
        //                 setState(() {
        //                   groupValueRequest = value!;
        //                 });
        //               },
        //             ),
        //             const Expanded(
        //               child: Text(
        //                 "Đòn gánh tới lấy",
        //                 overflow: TextOverflow.ellipsis,
        //                 style: TextStyle(fontSize: 15),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     const SizedBox(width: 20),
        //     Expanded(
        //       flex: 1,
        //       child: Container(
        //         child: Row(
        //           children: [
        //             Radio<String>(
        //               activeColor: const Color.fromRGBO(59, 99, 53, 1),
        //               value: "denlay",
        //               groupValue: groupValueRequest,
        //               onChanged: (value) {
        //                 setState(() {
        //                   groupValueRequest = value!;
        //                 });
        //               },
        //             ),
        //             const Expanded(
        //               child: Text(
        //                 "Tự tới lấy",
        //                 overflow: TextOverflow.ellipsis,
        //                 style: TextStyle(fontSize: 15),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ],
        // ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _createYeuCauDangKy,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(59, 99, 53, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Xác nhận',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget susccesDK() {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('lib/assets/img_success.png'),
            const SizedBox(height: 20),
            const Text(
              'Đăng ký thành công!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              textAlign: TextAlign.center,
              'Đơn đăng ký của bạn đã gửi đi. vui lòng chờ thông báo của chúng tôi.',
              style: TextStyle(fontSize: 13),
            ),
          ]),
    );
  }
}
