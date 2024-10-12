// ignore_for_file: prefer_const_constructors

import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayScreen1 extends StatefulWidget {
  final VoidCallback nextStep;
  const PayScreen1({super.key, required this.nextStep});

  @override
  State<PayScreen1> createState() => _PayScreen1State();
}

class _PayScreen1State extends State<PayScreen1> {
  String groupValue = "Anh";
  String groupValueRequest = "Giao hàng tại nhà";

  // Variables for address selection
  String? selectedTinhThanhPho;
  String? selectedQuanHuyen;
  String? selectedPhuongXa;

  // Controllers for input fields
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ghiChuController = TextEditingController();
  final TextEditingController duongThonController = TextEditingController();

  // Lists for DropdownSearch
  List<String> _tinhThanhPhoList = [];
  List<String> _quanHuyenList = [];
  List<String> _phuongXaList = [];

  bool _isLoading = true;
  bool _isOrderProcessing = false; // For handling order processing state

  // Selected items and products map
  List<ChiTietGioHang> selectedItems = [];
  Map<String, ProductModel> _productsMap = {};

  // To ensure products are fetched only once
  bool _productsFetched = false;

  @override
  void initState() {
    super.initState();
    _initializeDropdowns();
    _loadSavedAddress(); // Load saved address from SharedPreferences if available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_productsFetched) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is List<ChiTietGioHang>) {
        selectedItems = args;
        print('Selected Items: ${selectedItems.length}');
        selectedItems.forEach((item) {
          print('Product ID: ${item.variantModel.idProduct}');
        });
        _fetchAllProducts();
      } else {
        // Handle the case where arguments are missing or of incorrect type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy sản phẩm.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      _productsFetched = true;
    }
  }

  @override
  void dispose() {
    hoTenController.dispose();
    soDienThoaiController.dispose();
    emailController.dispose();
    ghiChuController.dispose();
    duongThonController.dispose();
    super.dispose();
  }

  // Initialize province/city list
  Future<void> _initializeDropdowns() async {
    try {
      _tinhThanhPhoList = await dcApiService().getProvinces();
      print('Fetched Provinces: $_tinhThanhPhoList');
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

  // Fetch all products based on selectedItems
  Future<void> _fetchAllProducts() async {
    setState(() {
      _isLoading = true;
    });

    // Extract unique product IDs
    Set<String> productIds =
        selectedItems.map((item) => item.variantModel.idProduct).toSet();
    print('Unique Product IDs: $productIds');

    try {
      // Fetch all products concurrently
      List<Future<ProductModel>> fetchFutures =
          productIds.map((id) => fetchProduct(id)).toList();

      List<ProductModel> products = await Future.wait(fetchFutures);
      print('Fetched Products: ${products.map((p) => p.id).toList()}');

      // Create a map from product ID to ProductModel
      _productsMap = {for (var product in products) product.id: product};
      print('_productsMap: $_productsMap');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải thông tin sản phẩm.')),
      );
    }
  }

  // Fetch districts based on selected province/city
  Future<void> _fetchQuanHuyen(String tinhThanhPho) async {
    try {
      _quanHuyenList = await dcApiService().getDistricts(tinhThanhPho);
      print('Fetched Districts for $tinhThanhPho: $_quanHuyenList');
      setState(() {
        selectedQuanHuyen = null; // Reset when province/city changes
        selectedPhuongXa = null; // Reset when district changes
        _phuongXaList = [];
      });
    } catch (e) {
      print('Error fetching districts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách Quận/Huyện.')),
      );
    }
  }

  // Fetch wards based on selected district
  Future<void> _fetchPhuongXa(String quanHuyen) async {
    try {
      _phuongXaList = await dcApiService().getWards(quanHuyen);
      print('Fetched Wards for $quanHuyen: $_phuongXaList');
      setState(() {
        selectedPhuongXa = null; // Reset when district changes
      });
    } catch (e) {
      print('Error fetching wards: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách Phường/Xã.')),
      );
    }
  }

  // Show address selection dialog
  Future<void> _showDiaChiDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId == null || storedUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy userId.')),
      );
      return;
    }

    try {
      // Fetch address list from API
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

                      // Update district and ward lists based on selected address
                      if (selectedTinhThanhPho != null &&
                          selectedTinhThanhPho!.isNotEmpty) {
                        await _fetchQuanHuyen(selectedTinhThanhPho!);
                      }
                      if (selectedQuanHuyen != null &&
                          selectedQuanHuyen!.isNotEmpty) {
                        await _fetchPhuongXa(selectedQuanHuyen!);
                      }

                      // Save selected address to SharedPreferences
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
    } catch (e) {
      print('Error fetching addresses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách địa chỉ.')),
      );
    }
  }

  // Save address to SharedPreferences
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

  // Load saved address from SharedPreferences
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

  // Fetch product data
  Future<ProductModel> fetchProduct(String productID) async {
    try {
      ProductModel product =
          await ProductApiService().getProductByID(productID);
      print('Fetched Product: ${product.id}');
      return product;
    } catch (e) {
      print('Error fetching product ID $productID: $e');
      throw e;
    }
  }

  // Method to create an order
Future<void> _createOrder() async {
  setState(() {
    _isOrderProcessing = true; // Bắt đầu quá trình xử lý đơn hàng
  });

  // Thu thập thông tin từ form
  String hoTen = hoTenController.text.trim();
  String soDienThoai = soDienThoaiController.text.trim();
  String email = emailController.text.trim();
  String yeuCauNhanHang = groupValueRequest; // Lấy yêu cầu nhận hàng
  String? tinhThanhPho = selectedTinhThanhPho;
  String? quanHuyen = selectedQuanHuyen;
  String? phuongXa = selectedPhuongXa;
  String duongThonXom = duongThonController.text.trim();
  String ghiChu = ghiChuController.text.trim();

  // Kiểm tra dữ liệu nhập vào
  if (_validateInput(hoTen, soDienThoai, email, tinhThanhPho, quanHuyen, phuongXa, duongThonXom)) {
    setState(() {
      _isOrderProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vui lòng điền đầy đủ thông tin khách hàng.')),
    );
    return;
  }

  // Tính tổng tiền
  double totalPrice = selectedItems.fold(0, (sum, item) => sum + (item.soLuong * item.donGia));
  print('Total Price: $totalPrice');

  try {
    // Lấy userId từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      setState(() {
        _isOrderProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID không tìm thấy. Vui lòng đăng nhập lại.')),
      );
      return;
    }

    // Tạo đối tượng địa chỉ mới
    diaChiList newAddress = diaChiList(
      tinhThanhPho: tinhThanhPho,
      quanHuyen: quanHuyen,
      phuongXa: phuongXa,
      duongThon: duongThonXom,
      name: hoTen,
      soDienThoai: soDienThoai,
    );

    // Chuyển đổi chi tiết giỏ hàng thành danh sách maps cho API
    List<ChiTietGioHang> chiTietGioHang = selectedItems.map((item) => ChiTietGioHang(
      id: item.id,
      variantModel: item.variantModel,
      soLuong: item.soLuong,
      donGia: item.donGia,
    )).toList();
    print('Cart Details: ${chiTietGioHang.map((item) => item.toJson()).toList()}');

    // ID giao dịch mẫu, thay thế bằng logic thực tế
    int transactionId = 151;

    // Gọi API để tạo đơn hàng
    var response = await OrderApiService().createUserDiaChivaThongTinGiaoHang(
      userId: userId,
      diaChiMoi: newAddress,
      ghiChu: ghiChu,
      khuyenmaiId: "66e8f14a8d3c9f33e31c200e", // ID khuyến mãi nếu có
      TongTien: totalPrice,
      selectedItems: chiTietGioHang,
      transactionId: transactionId,
      giohangId: "670492efb57221ab50c0baef",
      YeuCauNhanHang: yeuCauNhanHang,
    );

    // print('Order Response: $response');

    // Kiểm tra phản hồi và xử lý
    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt hàng thành công!')),
      );
      widget.nextStep(); // Chuyển sang bước tiếp theo
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt hàng thất bại: ${response}')),
      );
    }
  } catch (e) {
    print('Lỗi khi tạo hóa đơn flutter: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xảy ra lỗi khi đặt hàng.')),
    );
  } finally {
    setState(() {
      _isOrderProcessing = false; // Kết thúc quá trình xử lý
    });
  }
}


// Phương thức kiểm tra dữ liệu đầu vào
bool _validateInput(String hoTen, String soDienThoai, String email, String? tinhThanhPho, String? quanHuyen, String? phuongXa, String duongThonXom) {
  return hoTen.isEmpty ||
      soDienThoai.isEmpty ||
      email.isEmpty ||
      tinhThanhPho == null ||
      tinhThanhPho.isEmpty ||
      quanHuyen == null ||
      quanHuyen.isEmpty ||
      phuongXa == null ||
      phuongXa.isEmpty ||
      duongThonXom.isEmpty;
}

  @override
  Widget build(BuildContext context) {
    // Remove the local declaration of selectedItems in build
    // final List<ChiTietGioHang> selectedItems =
    //     ModalRoute.of(context)!.settings.arguments as List<ChiTietGioHang>;

    print('Building PayScreen1');
    print('Selected Items Count: ${selectedItems.length}');
    print('Products Map Keys: ${_productsMap.keys.toList()}');

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // List of products to be paid
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        final product =
                            _productsMap[item.variantModel.idProduct];

                        if (product == null) {
                          print(
                              'Product not found for ID: ${item.variantModel.idProduct}');
                          // Handle the case where the product was not fetched successfully
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[300],
                                      ),
                                      child:
                                          Icon(Icons.error, color: Colors.red),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Sản phẩm không tồn tại',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Không tìm thấy thông tin sản phẩm.',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
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
                                              padding: const EdgeInsets.only(
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
                                        Text('Đơn giá: ${item.donGia} đ/kg'),
                                        SizedBox(height: 4),
                                        Container(
                                          width: 120,
                                          height: 30,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${item.soLuong}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14),
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
                    ),
                  ),
                  // Customer information and address selection
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                      top:
                          BorderSide(color: Color.fromARGB(255, 204, 202, 202)),
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
                                activeColor: Color.fromRGBO(59, 99, 53, 1),
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
                                activeColor: Color.fromRGBO(59, 99, 53, 1),
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
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Row(
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
                                      Expanded(
                                        child: Text(
                                          "Giao hàng tại nhà",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Row(
                                    children: [
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
                                      Expanded(
                                        child: Text(
                                          "Nhận tại cửa hàng",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                    selectedItem:
                                        selectedTinhThanhPho!.isNotEmpty
                                            ? selectedTinhThanhPho
                                            : null,
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
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
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
                                    selectedItem: selectedQuanHuyen != null &&
                                            selectedQuanHuyen!.isNotEmpty
                                        ? selectedQuanHuyen
                                        : null,
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
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
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
                                    selectedItem: selectedPhuongXa != null &&
                                            selectedPhuongXa!.isNotEmpty
                                        ? selectedPhuongXa
                                        : null,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedPhuongXa = newValue;
                                      });
                                    },
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
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
                          // Notes for the seller
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
                          // Submit Button
                          _isOrderProcessing
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _createOrder();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(59, 99, 53, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Tiếp tục',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
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
