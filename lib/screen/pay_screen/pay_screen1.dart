import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayScreen1 extends StatefulWidget {
  const PayScreen1({super.key});

  @override
  State<PayScreen1> createState() => _PayScreen1State();
}

class _PayScreen1State extends State<PayScreen1> {
  String groupValue = "Anh";
  String groupValueRequest = "Giao hàng tại nhà";

  // Các biến trạng thái cho địa chỉ
  String? selectedTinhThanhPho;
  String? selectedQuanHuyen;
  String? selectedPhuongXa;

  // Controllers cho các trường nhập liệu
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ghiChuController = TextEditingController();
  final TextEditingController duongThonController = TextEditingController();

  // Danh sách các items cho DropdownSearch
  List<String> _tinhThanhPhoList = [];
  List<String> _quanHuyenList = [];
  List<String> _phuongXaList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDropdowns();
    _loadSavedAddress(); // Tải địa chỉ đã lưu từ SharedPreferences nếu có
  }

  // Phương thức khởi tạo các danh sách tỉnh/thành phố
  Future<void> _initializeDropdowns() async {
    try {
      _tinhThanhPhoList = await dcApiService().getProvinces();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách Tỉnh/Thành Phố.')),
      );
    }
  }

  // Phương thức lấy danh sách Quận/Huyện dựa trên Tỉnh/Thành Phố đã chọn
  Future<void> _fetchQuanHuyen(String tinhThanhPho) async {
    try {
      _quanHuyenList = await dcApiService().getDistricts(tinhThanhPho);
      setState(() {
        selectedQuanHuyen = null; // Reset khi thay đổi Tỉnh/Thành Phố
        selectedPhuongXa = null; // Reset khi thay đổi Quận/Huyện
        _phuongXaList = [];
      });
    } catch (e) {
      print('Error fetching districts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách Quận/Huyện.')),
      );
    }
  }

  // Phương thức lấy danh sách Phường/Xã dựa trên Quận/Huyện đã chọn
  Future<void> _fetchPhuongXa(String quanHuyen) async {
    try {
      _phuongXaList = await dcApiService().getWards(quanHuyen);
      setState(() {
        selectedPhuongXa = null; // Reset khi thay đổi Quận/Huyện
      });
    } catch (e) {
      print('Error fetching wards: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách Phường/Xã.')),
      );
    }
  }

  // Phương thức hiển thị dialog chọn địa chỉ
  Future<void> _showDiaChiDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId == null || storedUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy userId.')),
      );
      return;
    }

    // Gọi API để lấy danh sách địa chỉ
    List<diaChiList> addresses =
        await DiaChiApiService().getDiaChiByUserId(storedUserId);

    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn chưa có địa chỉ nào.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn địa chỉ'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return ListTile(
                  title: Text(address.name ?? 'Tên không có'),
                  subtitle: Text(
                    '${address.soDienThoai} \n${address.tinhThanhPho}, ${address.quanHuyen}, ${address.phuongXa}, ${address.duongThon}',
                  ),
                  onTap: () async {
                    setState(() {
                      selectedTinhThanhPho = address.tinhThanhPho ?? '';
                      selectedQuanHuyen = address.quanHuyen ?? '';
                      selectedPhuongXa = address.phuongXa ?? '';

                      hoTenController.text = address.name ?? '';
                      soDienThoaiController.text = address.soDienThoai ?? '';
                      duongThonController.text = address.duongThon ?? '';
                    });

                    // Cập nhật danh sách Quận/Huyện và Phường/Xã dựa trên địa chỉ đã chọn
                    if (selectedTinhThanhPho != null &&
                        selectedTinhThanhPho!.isNotEmpty) {
                      await _fetchQuanHuyen(selectedTinhThanhPho!);
                    }
                    if (selectedQuanHuyen != null &&
                        selectedQuanHuyen!.isNotEmpty) {
                      await _fetchPhuongXa(selectedQuanHuyen!);
                    }

                    // Lưu địa chỉ đã chọn vào SharedPreferences
                    await _saveAddressToPreferences();

                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Lưu địa chỉ vào SharedPreferences
  Future<void> _saveAddressToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTinhThanhPho', selectedTinhThanhPho ?? '');
    await prefs.setString('selectedQuanHuyen', selectedQuanHuyen ?? '');
    await prefs.setString('selectedPhuongXa', selectedPhuongXa ?? '');
    await prefs.setString('hoTen', hoTenController.text);
    await prefs.setString('soDienThoai', soDienThoaiController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('duongThon', duongThonController.text);
    await prefs.setString('ghiChu', ghiChuController.text);
  }

  // Tải địa chỉ đã lưu từ SharedPreferences
  Future<void> _loadSavedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTinhThanhPho = prefs.getString('selectedTinhThanhPho') ?? '';
      selectedQuanHuyen = prefs.getString('selectedQuanHuyen') ?? '';
      selectedPhuongXa = prefs.getString('selectedPhuongXa') ?? '';
      hoTenController.text = prefs.getString('hoTen') ?? '';
      soDienThoaiController.text = prefs.getString('soDienThoai') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      duongThonController.text = prefs.getString('duongThon') ?? '';
      ghiChuController.text = prefs.getString('ghiChu') ?? '';
    });

    if (selectedTinhThanhPho != null && selectedTinhThanhPho!.isNotEmpty) {
      await _fetchQuanHuyen(selectedTinhThanhPho!);
    }

    if (selectedQuanHuyen != null && selectedQuanHuyen!.isNotEmpty) {
      await _fetchPhuongXa(selectedQuanHuyen!);
    }
  }

  // Phương thức lấy dữ liệu sản phẩm
  Future<ProductModel> fetchProduct(String productID) async {
    return await ProductApiService().getProductByID(productID);
  }

  @override
  Widget build(BuildContext context) {
    final List<ChiTietGioHang> selectedItems =
        ModalRoute.of(context)!.settings.arguments as List<ChiTietGioHang>;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // List sản phẩm sẽ thanh toán
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        return FutureBuilder<ProductModel>(
                          future: fetchProduct(item.variantModel.idProduct),
                          builder: (context, productSnapshot) {
                            if (!productSnapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            ProductModel product = productSnapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  product.imageProduct),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.nameProduct,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: item
                                                  .variantModel.ketHopThuocTinh
                                                  .map((thuocTinh) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Text(
                                                    thuocTinh
                                                        .giaTriThuocTinh.GiaTri,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                                'Đơn giá: ${item.donGia} đ/kg'),
                                            SizedBox(height: 4),
                                            Container(
                                              width: 120,
                                              height: 30,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${item.soLuong}",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Thông tin khách hàng và chọn địa chỉ
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                      top: BorderSide(color: Color.fromARGB(255, 204, 202, 202)),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin khách hàng',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '*Những thông tin ở đây là thông tin mặc định của quý khách và những thay đổi ở đây sẽ không được lưu.',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(height: 16),
                          // Radio Buttons for Gender
                          Row(
                            children: [
                              Radio<String>(
                                activeColor:
                                    Color.fromRGBO(59, 99, 53, 1),
                                value: "Anh",
                                groupValue: groupValue,
                                onChanged: (value) {
                                  setState(() {
                                    groupValue = value!;
                                  });
                                },
                              ),
                              Text(
                                "Anh",
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(width: 20),
                              Radio<String>(
                                activeColor:
                                    Color.fromRGBO(59, 99, 53, 1),
                                value: "Chị",
                                groupValue: groupValue,
                                onChanged: (value) {
                                  setState(() {
                                    groupValue = value!;
                                  });
                                },
                              ),
                              Text(
                                "Chị",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          TextButton(
                            onPressed: _showDiaChiDialog,
                            child: Text('Chọn địa chỉ'),
                          ),
                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Yêu cầu nhận hàng",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          // Radio Buttons for Delivery Request
                          Row(
                            children: [
                              Radio<String>(
                                activeColor:
                                    Color.fromRGBO(59, 99, 53, 1),
                                value: "Giao hàng tại nhà",
                                groupValue: groupValueRequest,
                                onChanged: (value) {
                                  setState(() {
                                    groupValueRequest = value!;
                                  });
                                },
                              ),
                              Text(
                                "Giao hàng tại nhà",
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(width: 20),
                              Radio<String>(
                                activeColor:
                                    Color.fromRGBO(59, 99, 53, 1),
                                value: "Nhận tại cửa hàng",
                                groupValue: groupValueRequest,
                                onChanged: (value) {
                                  setState(() {
                                    groupValueRequest = value!;
                                  });
                                },
                              ),
                              Text(
                                "Nhận tại cửa hàng",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Address Dropdowns
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownSearch<String>(
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                    ),
                                    items: _tinhThanhPhoList,
                                    // selectedItem: selectedTinhThanhPho.isNotEmpty
                                    //     ? selectedTinhThanhPho
                                    //     : null,
                                    onChanged: (newValue) async {
                                      setState(() {
                                        selectedTinhThanhPho = newValue;
                                        selectedQuanHuyen = null;
                                        selectedPhuongXa = null;
                                        _quanHuyenList = [];
                                        _phuongXaList = [];
                                      });
                                      if (newValue != null) {
                                        await _fetchQuanHuyen(newValue);
                                      }
                                    },
                                    dropdownDecoratorProps: DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: 'Tỉnh/Thành Phố',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownSearch<String>(
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                    ),
                                    items: _quanHuyenList,
                                    // selectedItem: selectedQuanHuyen.isNotEmpty
                                    //     ? selectedQuanHuyen
                                    //     : null,
                                    onChanged: (newValue) async {
                                      setState(() {
                                        selectedQuanHuyen = newValue;
                                        selectedPhuongXa = null;
                                        _phuongXaList = [];
                                      });
                                      if (newValue != null) {
                                        await _fetchPhuongXa(newValue);
                                      }
                                    },
                                    dropdownDecoratorProps: DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Quận/Huyện",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownSearch<String>(
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                    ),
                                    items: _phuongXaList,
                                    // selectedItem: selectedPhuongXa.contains()
                                    //     ? selectedPhuongXa
                                    //     : null,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedPhuongXa = newValue;
                                      });
                                    },
                                    dropdownDecoratorProps: DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Phường/Xã",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Ghi chú cho người bán
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Ghi chú cho người bán",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: ghiChuController,
                              maxLines: 6,
                              minLines: 5,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                hintText: 'Gõ vào đây',
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
