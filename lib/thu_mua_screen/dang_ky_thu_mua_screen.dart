import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/yeu_cau_dang_ky_thu_mua_api_service.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
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

  List<String> tinhThanhPhoList = [];
  List<String> quanHuyenList = [];
  List<String> phuongXaList = [];

  String groupValueRequest = "tugiao";
  String? selectedTinh;
  String? selectedQuan;
  String? selectedPhuong;
  String? hoTen;
  String? soDienThoai;
  String? duongThon;
  String? userId;
  bool isSucces = false;

  final _yeuCauDangKyService = YeuCauDangKyService();
  final DcApiService apiService = DcApiService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTinhThanhPho();
  }

  Future<void> _loadTinhThanhPho() async {
    try {
      final provinces = await apiService.getTinhThanhPho();
      setState(() {
        tinhThanhPhoList = provinces;
      });
    } catch (e) {
      print("Error loading provinces: $e");
    }
  }

  Future<void> _loadQuanHuyen() async {
    try {
      final districts = await apiService.getQuanHuyen();
      setState(() {
        quanHuyenList = districts;
        selectedQuan = null;
        selectedPhuong = null;
        phuongXaList = [];
      });
    } catch (e) {
      print("Error loading districts: $e");
    }
  }

  Future<void> _loadPhuongXa() async {
    try {
      final wards = await apiService.getPhuongXa();
      setState(() {
        phuongXaList = wards;
        selectedPhuong = null;
      });
    } catch (e) {
      print("Error loading wards: $e");
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
        selectedTinh!.isEmpty ||
        selectedQuan!.isEmpty ||
        selectedPhuong!.isEmpty ||
        duongThonController.text.isEmpty) {
      _showSnackbar("Vui lòng điền đầy đủ thông tin.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    diaChiList newAddress = diaChiList(
      tinhThanhPho: selectedTinh!,
      quanHuyen: selectedQuan!,
      phuongXa: selectedPhuong!,
      duongThon: duongThon!,
      name: hoTen,
      soDienThoai: soDienThoai,
    );

    try {
      final response = await _yeuCauDangKyService.createYeuCauDangKy(
        userId: userId!, // Replace with actual userId
        ghiChu: hoTenController.text,
        soluongloaisanpham: int.parse(soluongLoaiController.text),
        soluongsanpham: int.parse(soluongSanPhamController.text),
        diaChiMoi: newAddress,
        hinhthucgiaohang: groupValueRequest,
      );

      if (response.isNotEmpty) {
        _showSnackbar("Đăng ký thành công!");
        // Optionally reset form
        hoTenController.clear();
        soDienThoaiController.clear();
        emailController.clear();
        duongThonController.clear();
        soluongLoaiController.clear();
        soluongSanPhamController.clear();
        setState(() {
          isSucces = true;
          selectedTinh = "";
          selectedQuan = "";
          selectedPhuong = "";
          groupValueRequest = "Đòn gánh tới lấy";
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
        Row(
          children: [
            Expanded(
              flex: 6,
              child: TextField(
                controller: hoTenController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                controller: soDienThoaiController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
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
              child: DropdownSearch<String>(
                items: tinhThanhPhoList,
                onChanged: (value) {
                  setState(() {
                    selectedTinh = value;
                    _loadQuanHuyen();
                  });
                },
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Tỉnh/Thành Phố',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 4,
              child: DropdownSearch<String>(
                items: quanHuyenList,
                onChanged: (value) {
                  setState(() {
                    selectedQuan = value;
                    _loadPhuongXa();
                  });
                },
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Quận/Huyện",
                    border: OutlineInputBorder(),
                  ),
                ),
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
              child: DropdownSearch<String>(
                items: phuongXaList,
                onChanged: (value) {
                  setState(() {
                    selectedPhuong = value;
                  });
                },
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Phường/Xã",
                    border: OutlineInputBorder(),
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
                controller: duongThonController,
                decoration: InputDecoration(
                  labelText: 'Đường/Thôn xóm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
