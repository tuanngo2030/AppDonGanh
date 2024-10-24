// ignore_for_file: prefer_const_constructors

import 'package:don_ganh_app/api_services/address_api.dart';
import 'package:don_ganh_app/api_services/diachi_api.dart';
import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String hoTenController = '';
  String soDienThoaiController = '';
  final TextEditingController ghiChuController = TextEditingController();
  String duongThonController = '';

  bool _isLoading = true;
  bool _isOrderProcessing = false; // For handling order processing state

  // Selected items and products map
  List<ChiTietGioHang> selectedItems = [];
  Map<String, ProductModel> _productsMap = {};

  // To ensure products are fetched only once
  bool _productsFetched = false;

  final OrderApiService _orderApiService = OrderApiService();

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();
  }

  Future<void> _fetchDefaultAddress() async {
    try {
      // Giả sử có một service để lấy danh sách địa chỉ từ API
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUserId = prefs.getString('userId');

      if (storedUserId != null) {
        List<diaChiList> addresses =
            await DiaChiApiService().getDiaChiByUserId(storedUserId);

        // Nếu có địa chỉ trong danh sách, chọn địa chỉ đầu tiên làm mặc định
        if (addresses.isNotEmpty) {
          setState(() {
            final firstAddress = addresses[0];
            selectedTinhThanhPho = firstAddress.tinhThanhPho ?? '';
            selectedQuanHuyen = firstAddress.quanHuyen ?? '';
            selectedPhuongXa = firstAddress.phuongXa ?? '';

            hoTenController = firstAddress.name ?? '';
            soDienThoaiController = firstAddress.soDienThoai ?? '';
            duongThonController = firstAddress.duongThon ?? '';
            _isLoading = false; // Dừng hiển thị loading khi đã có dữ liệu
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bạn chưa có địa chỉ nào.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách địa chỉ.')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_productsFetched) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is List<ChiTietGioHang>) {
        selectedItems = args;
        print('Selected Items: ${selectedItems.length}');
        for (var item in selectedItems) {
          print('Product ID: ${item.variantModel.idProduct}');
        }
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
            content: SizedBox(
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

                        hoTenController = address.name ?? '';
                        soDienThoaiController = address.soDienThoai ?? '';
                        duongThonController = address.duongThon ?? '';
                      });

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

  // Fetch product data
  Future<ProductModel> fetchProduct(String productID) async {
    try {
      ProductModel product =
          await ProductApiService().getProductByID(productID);
      print('Fetched Product: ${product.id}');
      return product;
    } catch (e) {
      print('Error fetching product ID $productID: $e');
      rethrow;
    }
  }

  Future<void> _createOrUpdateOrder() async {
    setState(() {
      _isOrderProcessing = true;
    });

    // Thu thập thông tin từ form
    String hoTen = hoTenController;
    String soDienThoai = soDienThoaiController;
    String yeuCauNhanHang = groupValueRequest;
    String? tinhThanhPho = selectedTinhThanhPho;
    String? quanHuyen = selectedQuanHuyen;
    String? phuongXa = selectedPhuongXa;
    String duongThonXom = duongThonController;
    String ghiChu = ghiChuController.text.trim().isEmpty
        ? 'Không có ghi chú'
        : ghiChuController.text
            .trim(); // Kiểm tra và gán giá trị chuỗi rỗng nếu trống

    // Kiểm tra dữ liệu nhập vào
    if (_validateInput(
        hoTen, soDienThoai, tinhThanhPho, quanHuyen, phuongXa, duongThonXom)) {
      setState(() {
        _isOrderProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin khách hàng.')),
      );
      return;
    }

    double totalPrice = selectedItems.fold(
        0, (sum, item) => sum + (item.soLuong * item.donGia));
    print('Total Price: $totalPrice');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        setState(() {
          _isOrderProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User ID không tìm thấy. Vui lòng đăng nhập lại.')),
        );
        return;
      }

      diaChiList newAddress = diaChiList(
        tinhThanhPho: tinhThanhPho!,
        quanHuyen: quanHuyen!,
        phuongXa: phuongXa!,
        duongThon: duongThonXom,
        name: hoTen,
        soDienThoai: soDienThoai,
      );

      // Chuyển đổi chi tiết giỏ hàng thành danh sách đối tượng
      List<ChiTietGioHang> chiTietGioHang = selectedItems
          .map((item) => ChiTietGioHang(
                id: item.id,
                variantModel: item.variantModel,
                soLuong: item.soLuong,
                donGia: item.donGia,
              ))
          .toList();

      // Lấy thông tin `order_id` từ Provider
      PaymentInfo paymentInfo =
          Provider.of<PaymentInfo>(context, listen: false);
      String? orderId = paymentInfo.order_id;

      if (orderId.isNotEmpty) {
        // Nếu đã có `order_id`, cập nhật địa chỉ và ghi chú cho hóa đơn
        await _orderApiService.updateDiaChiGhiChuHoaDon(
          hoadonId: orderId,
          diaChiMoi: newAddress,
          ghiChu: ghiChu,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật địa chỉ và ghi chú thành công!')),
        );

         // Cập nhật thông tin `order_id` trong Provider
        paymentInfo.updateInfo(
          order_id: orderId,
          hoTen: hoTen,
          soDienThoai: soDienThoai,
          email: '',
          yeuCauNhanHang: yeuCauNhanHang,
          tinhThanhPho: tinhThanhPho,
          quanHuyen: quanHuyen,
          phuongXa: phuongXa,
          duongThonXom: duongThonXom,
          ghiChu: ghiChu,
          selectedItems: selectedItems,
          totalPrice: totalPrice,
          
        );
         widget.nextStep();
      } else {
        // Nếu chưa có `order_id`, tạo đơn hàng mới
        OrderModel? response =
            await _orderApiService.createUserDiaChivaThongTinGiaoHang(
          userId: userId,
          diaChiMoi: newAddress,
          ghiChu: ghiChu,
          khuyenmaiId: "66e8f14a8d3c9f33e31c200e", // ID khuyến mãi nếu có
          TongTien: totalPrice,
          selectedItems: chiTietGioHang,
        );

        print('Order Response: $response');

        // Cập nhật thông tin `order_id` trong Provider
        paymentInfo.updateInfo(
          order_id: response.id,
          hoTen: hoTen,
          soDienThoai: soDienThoai,
          email: '',
          yeuCauNhanHang: yeuCauNhanHang,
          tinhThanhPho: tinhThanhPho,
          quanHuyen: quanHuyen,
          phuongXa: phuongXa,
          duongThonXom: duongThonXom,
          ghiChu: ghiChu,
          selectedItems: selectedItems,
          totalPrice: totalPrice,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt hàng thành công!')),
        );
        widget.nextStep();
      }
    } catch (e) {
      print('Lỗi khi tạo/cập nhật hóa đơn: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi xử lý đơn hàng.')),
      );
    } finally {
      setState(() {
        _isOrderProcessing = false; // Kết thúc quá trình xử lý
      });
    }
  }

// Phương thức kiểm tra dữ liệu đầu vào
  bool _validateInput(
      String hoTen,
      String soDienThoai,
      // String email,
      String? tinhThanhPho,
      String? quanHuyen,
      String? phuongXa,
      String duongThonXom) {
    return hoTen.isEmpty ||
        soDienThoai.isEmpty ||
        // email.isEmpty ||
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
    print('Building PayScreen1');
    print('Selected Items Count: ${selectedItems.length}');
    print('Products Map Keys: ${_productsMap.keys.toList()}');

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
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
                                        SizedBox(
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
                          // Row(
                          //   children: [
                          //     Radio<String>(
                          //       activeColor: Color.fromRGBO(59, 99, 53, 1),
                          //       value: "Anh",
                          //       groupValue: groupValue,
                          //       onChanged: (value) {
                          //         setState(() {
                          //           groupValue = value!;
                          //         });
                          //       },
                          //     ),
                          //     Text(
                          //       "Anh",
                          //       style: TextStyle(fontSize: 15),
                          //     ),
                          //     SizedBox(width: 20),
                          //     Radio<String>(
                          //       activeColor: Color.fromRGBO(59, 99, 53, 1),
                          //       value: "Chị",
                          //       groupValue: groupValue,
                          //       onChanged: (value) {
                          //         setState(() {
                          //           groupValue = value!;
                          //         });
                          //       },
                          //     ),
                          //     Text(
                          //       "Chị",
                          //       style: TextStyle(fontSize: 15),
                          //     ),
                          //   ],
                          // ),
                          SizedBox(height: 16),

                          TextButton(
                            onPressed: _showDiaChiDialog,
                            child: Text('Chọn địa chỉ'),
                          ),
                          SizedBox(height: 16),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       flex: 6,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: TextField(
                          //           controller: hoTenController,
                          //           decoration: InputDecoration(
                          //             labelText: 'Họ và tên',
                          //             border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       flex: 4,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: TextField(
                          //           controller: soDienThoaiController,
                          //           keyboardType: TextInputType.phone,
                          //           decoration: InputDecoration(
                          //             labelText: 'Số điện thoại',
                          //             border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: TextField(
                          //     controller: emailController,
                          //     keyboardType: TextInputType.emailAddress,
                          //     decoration: InputDecoration(
                          //       labelText: 'Email',
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(8),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.fromBorderSide(
                                    BorderSide(width: 1, color: Colors.grey))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Người nhận hàng: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '$hoTenController, $soDienThoaiController',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Địa chỉ nhận: ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '$duongThonController, $selectedPhuongXa, $selectedQuanHuyen, $selectedTinhThanhPho',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       flex: 6,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: DropdownSearch<String>(
                          //           popupProps: PopupProps.menu(
                          //             showSearchBox: true,
                          //           ),
                          //           items: _tinhThanhPhoList,
                          //           selectedItem:
                          //               selectedTinhThanhPho!.isNotEmpty
                          //                   ? selectedTinhThanhPho
                          //                   : null,
                          //           onChanged: (newValue) async {
                          //             setState(() {
                          //               selectedTinhThanhPho = newValue;
                          //               selectedQuanHuyen = null;
                          //               selectedPhuongXa = null;
                          //               _quanHuyenList = [];
                          //               _phuongXaList = [];
                          //             });
                          //             if (newValue != null) {
                          //               // await _fetchQuanHuyen(newValue);
                          //             }
                          //           },
                          //           dropdownDecoratorProps:
                          //               DropDownDecoratorProps(
                          //             dropdownSearchDecoration: InputDecoration(
                          //               labelText: 'Tỉnh/Thành Phố',
                          //               border: OutlineInputBorder(),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       flex: 4,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: DropdownSearch<String>(
                          //           popupProps: PopupProps.menu(
                          //             showSearchBox: true,
                          //           ),
                          //           items: _quanHuyenList,
                          //           selectedItem: selectedQuanHuyen != null &&
                          //                   selectedQuanHuyen!.isNotEmpty
                          //               ? selectedQuanHuyen
                          //               : null,
                          //           onChanged: (newValue) async {
                          //             setState(() {
                          //               selectedQuanHuyen = newValue;
                          //               selectedPhuongXa = null;
                          //               _phuongXaList = [];
                          //             });
                          //             if (newValue != null) {
                          //               await _fetchPhuongXa(newValue);
                          //             }
                          //           },
                          //           dropdownDecoratorProps:
                          //               DropDownDecoratorProps(
                          //             dropdownSearchDecoration: InputDecoration(
                          //               labelText: "Quận/Huyện",
                          //               border: OutlineInputBorder(),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       flex: 6,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: DropdownSearch<String>(
                          //           popupProps: PopupProps.menu(
                          //             showSearchBox: true,
                          //           ),
                          //           items: _phuongXaList,
                          //           selectedItem: selectedPhuongXa != null &&
                          //                   selectedPhuongXa!.isNotEmpty
                          //               ? selectedPhuongXa
                          //               : null,
                          //           onChanged: (newValue) {
                          //             setState(() {
                          //               selectedPhuongXa = newValue;
                          //             });
                          //           },
                          //           dropdownDecoratorProps:
                          //               DropDownDecoratorProps(
                          //             dropdownSearchDecoration: InputDecoration(
                          //               labelText: "Phường/Xã",
                          //               border: OutlineInputBorder(),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       flex: 4,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: TextField(
                          //           controller: duongThonController,
                          //           decoration: InputDecoration(
                          //             labelText: 'Đường/Thôn xóm',
                          //             border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
                                       _createOrUpdateOrder();
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
