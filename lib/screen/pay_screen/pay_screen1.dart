import 'package:don_ganh_app/Profile_Screen/dia_chi_screen.dart';
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
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
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
  List<CartModel> selectedItems = [];

  final Map<String, ProductModel> _productsMap = {};

  // To ensure products are fetched only once
  final bool _productsFetched = false;
  double totalAmount = 0.0;

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
            const SnackBar(content: Text('Bạn chưa có địa chỉ nào.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách địa chỉ.')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nhận dữ liệu từ arguments trong didChangeDependencies
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List<CartModel>) {
      setState(() {
        selectedItems = args;
      });
    }
  }

  void _navigateToAddAddress() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddressScreen(), // Điều hướng đến trang thêm địa chỉ
      ),
    ).then((result) {
      if (result == true) {
        _showDiaChiDialog(); // Gọi lại hộp thoại chọn địa chỉ sau khi thêm
      }
    });
  }

// Phương thức hiển thị hộp thoại chọn địa chỉ
  Future<void> _showDiaChiDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId == null || storedUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy userId.')),
      );
      return;
    }

    try {
      // Gọi API để lấy danh sách địa chỉ
      List<diaChiList> addresses =
          await DiaChiApiService().getDiaChiByUserId(storedUserId);

      if (addresses.isEmpty) {
        // Chuyển đến màn hình thêm địa chỉ nếu không có địa chỉ nào
        _navigateToAddAddress();
        return;
      }

      // Hiển thị hộp thoại nếu có địa chỉ
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Chọn địa chỉ'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  ListView.builder(
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
                          // Cập nhật các trường địa chỉ đã chọn
                          setState(() {
                            selectedTinhThanhPho = address.tinhThanhPho ?? '';
                            selectedQuanHuyen = address.quanHuyen ?? '';
                            selectedPhuongXa = address.phuongXa ?? '';

                            hoTenController = address.name ?? '';
                            soDienThoaiController = address.soDienThoai ?? '';
                            duongThonController = address.duongThon ?? '';
                          });

                          Navigator.of(context).pop(); // Đóng hộp thoại
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _navigateToAddAddress,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the icon and text
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                4), // Add some padding inside the border
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(
                                    59, 99, 53, 1), // Border color
                                width: 1, // Border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(100), // Rounded corners
                            ),
                            child: const Icon(
                              size: 20,
                              Icons.add, // Icon
                              color:
                                  Color.fromRGBO(59, 99, 53, 1), // Icon color
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8), // Add some spacing between the icon and text
                          const Text('Thêm địa chỉ mới',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromRGBO(59, 99, 53, 1))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching addresses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách địa chỉ.')),
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

  double calculateTotal(List<CartModel> selectedItems) {
    double total = 0.0;

    // Duyệt qua danh sách CartModel
    for (var cart in selectedItems) {
      // Duyệt qua danh sách SanPhamCart trong mỗi CartModel
      for (var sanPhamCart in cart.mergedCart) {
        // Duyệt qua danh sách SanPhamList trong mỗi SanPhamCart
        for (var sanPhamItem in sanPhamCart.sanPhamList) {
          // Duyệt qua danh sách ChiTietGioHang trong mỗi SanPhamList
          for (var chiTiet in sanPhamItem.chiTietGioHangs) {
            // Tính tổng: số lượng * đơn giá
            total += chiTiet.soLuong * chiTiet.donGia;
          }
        }
      }
    }
    return total;
  }

  Future<void> _createOrUpdateOrder() async {
    print(' hihi: $selectedItems');
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
        const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin khách hàng.')),
      );
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        setState(() {
          _isOrderProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User ID không tìm thấy. Vui lòng đăng nhập lại.')),
        );
        return;
      }

      // Calculate total price
      double totalPrice = calculateTotal(selectedItems);
      print('Total Price: $totalPrice');

      diaChiList newAddress = diaChiList(
        tinhThanhPho: tinhThanhPho!,
        quanHuyen: quanHuyen!,
        phuongXa: phuongXa!,
        duongThon: duongThonXom,
        name: hoTen,
        soDienThoai: soDienThoai,
      );

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
          const SnackBar(
              content: Text('Cập nhật địa chỉ và ghi chú thành công!')),
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
          khuyenmaiId: "", // ID khuyến mãi nếu có
          TongTien: totalPrice,
          selectedItems: selectedItems,
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
          totalPrice: 10,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công!')),
        );
        widget.nextStep();
      }
    } catch (e) {
      print(selectedItems);
      print('Lỗi khi tạo/cập nhật hóa đơn: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi khi xử lý đơn hàng.')),
      );
    } finally {
      setState(() {
        _isOrderProcessing = false;
      });
    }
  }

  bool _validateInput(String hoTen, String soDienThoai, String? tinhThanhPho,
      String? quanHuyen, String? phuongXa, String duongThonXom) {
    return hoTen.isEmpty ||
        soDienThoai.isEmpty ||
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
    final List<CartModel> selectedCart =
        ModalRoute.of(context)?.settings.arguments as List<CartModel>;
    print('Building PayScreen1');
    print('Selected Items Count: ${selectedCart.length}');

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: selectedCart.map((cart) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cart.mergedCart.map((sanPhamCart) {
                            double userTotal = 0.0;
                            int totalProducts = 0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  color: Colors.grey[200],
                                  child: Text(
                                    sanPhamCart.user.tenNguoiDung!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...sanPhamCart.sanPhamList.map((sanPhamItem) {
                                  return Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Column(
                                      children: sanPhamItem.chiTietGioHangs
                                          .map((chiTiet) {
                                        userTotal +=
                                            chiTiet.donGia * chiTiet.soLuong;
                                                 totalProducts += chiTiet.soLuong; // Count the total number of products


                                        return Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  sanPhamItem.sanPham
                                                          .imageProduct ??
                                                      '',
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Loại sản phẩm: ${chiTiet.variantModel.ketHopThuocTinh.map((thuocTinh) => thuocTinh.giaTriThuocTinh.GiaTri).join(', ')}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        'Số lượng: ${chiTiet.soLuong}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        'Đơn giá:${NumberFormat("#,##0").format(chiTiet.donGia)} VND',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: Text(
                                       'Tổng số tiền ($totalProducts sản phẩm): ${NumberFormat("#,###").format(userTotal)} VND',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                  // Customer information and address selection
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin khách hàng',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '*Những thông tin ở đây là thông tin mặc định của quý khách và những thay đổi ở đây sẽ không được lưu.',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: _showDiaChiDialog,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              backgroundColor: const Color.fromRGBO(
                                  41, 87, 35, 1), // Màu nền của nút
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // Bo góc nút
                              ),
                            ),
                            child: const Text(
                              'Chọn địa chỉ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white), // Văn bản trên nút
                            ),
                          ),
                          const SizedBox(height: 16),

                          hoTenController.isEmpty || duongThonController.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Bạn chưa có địa chỉ nào.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: const Border.fromBorderSide(
                                          BorderSide(
                                              width: 1, color: Colors.grey))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    fontWeight:
                                                        FontWeight.normal,
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

                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
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
                                            const Color.fromRGBO(59, 99, 53, 1),
                                        value: "Giao hàng tại nhà",
                                        groupValue: groupValueRequest,
                                        onChanged: (value) {
                                          setState(() {
                                            groupValueRequest = value!;
                                          });
                                        },
                                      ),
                                      const Expanded(
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
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        activeColor:
                                            const Color.fromRGBO(59, 99, 53, 1),
                                        value: "Nhận tại cửa hàng",
                                        groupValue: groupValueRequest,
                                        onChanged: (value) {
                                          setState(() {
                                            groupValueRequest = value!;
                                          });
                                        },
                                      ),
                                      const Expanded(
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
                          const SizedBox(height: 16),

                          // Notes for the seller
                          const Padding(
                            padding: EdgeInsets.all(8.0),
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
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Submit Button
                          _isOrderProcessing
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _createOrUpdateOrder();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(59, 99, 53, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
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
