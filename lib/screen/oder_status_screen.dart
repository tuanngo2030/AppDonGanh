import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/oder_model_for_hokinhdoanh.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:don_ganh_app/screen/order_review_screen.dart';
import 'package:don_ganh_app/screen/pay_screen/choose_payment_screen.dart';
import 'package:don_ganh_app/screen/pay_screen/exprire_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OderStatusScreen extends StatefulWidget {
  final OrderModel orderModel;
  const OderStatusScreen({super.key, required this.orderModel});

  @override
  State<OderStatusScreen> createState() => _OderStatusScreenState();
}

class _OderStatusScreenState extends State<OderStatusScreen> {
  late int status;
  bool dialogShown = false;
  bool showExprireButton = false;
  late Future<OrderModelForHoKinhDoanh> _orderFuture;
  String? selectedProductId; // Biến để lưu ID sản phẩm hiện tại

  @override
  void initState() {
    super.initState();
    status = widget.orderModel.TrangThai;
    _orderFuture = OrderApiService().getHoaDonByHoaDonId(widget.orderModel.id);

    // Check if transactionId is neither 0 nor 111 and payment status is false, then show the extension notification
    if (widget.orderModel.transactionId != 0 &&
        widget.orderModel.transactionId != 111 &&
        !widget.orderModel.thanhToan &&
        widget.orderModel.TrangThai < 3) {
      _checkBaoKimStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Show payment method dialog if transactionId is 0 and dialog hasn't been shown
    if (widget.orderModel.transactionId == 0 &&
        !dialogShown &&
        widget.orderModel.TrangThai == 0) {
      dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPaymentMethodDialog();
      });
    }
  }

  // Hàm lưu ID vào biến
  void saveProductId(String? productId) {
    setState(() {
      selectedProductId = productId; // Lưu ID vào biến
    });
  }

  Future<void> _checkBaoKimStatus() async {
    final orderApiService = OrderApiService();

    try {
      final response = await orderApiService.checkDonHangBaoKim(
        orderId: widget.orderModel.id,
      );

      print(response); // Log response to confirm structure and values

      // Check if order is expired
      if (mounted && response.containsKey('message')) {
        final statusMessage = response['message'];

        if (statusMessage == 'Đơn hàng đã hết hạn') {
          _showGiaHanBaoKimDialog(); // Show dialog for expired order
        } else if (statusMessage == 'Đơn hàng Chưa thanh toán') {
          setState(() {
            showExprireButton =
                true; // Show the button to navigate to ExprireScreen
          });
          print("Order is pending.");
        } else if (statusMessage == 'Order paid successfully') {
          // Order has been paid, handle accordingly if needed
          print("Order has been paid successfully.");
        } else if (statusMessage == 'Order canceled or failed') {
          // Order was canceled or failed
          print("Order was canceled or failed.");
        } else {
          // Unexpected status message
          print("Unexpected order status: $statusMessage");
        }
      } else {
        print("Failed to retrieve 'message' from response");
      }
    } catch (error) {
      print("Failed to check Bảo Kim status: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi kiểm tra trạng thái đơn hàng Bảo Kim.'),
          ),
        );
      }
    }
  }

// Show notification for extending Bảo Kim
  void _showGiaHanBaoKimDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gia hạn Bảo Kim'),
            content: const Text(
                'Thanh toán online Bảo Kim đã hết hạn. Bạn có muốn gia hạn để tiếp tục xử lý?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _giaHanHoaDon();
                },
                child: const Text('Gia hạn'),
              ),
            ],
          );
        },
      );
    }
  }

// Show dialog to select payment method
  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bạn chưa chọn phương thức thanh toán'),
          content: const Text('Bạn có muốn chọn phương thức thanh toán không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChoosePaymentScreen(orderModel: widget.orderModel),
                  ),
                );
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }

  Color _getColor(int step) {
    return (step <= status) ? const Color.fromRGBO(41, 87, 35, 1) : Colors.grey;
  }

  Future<void> _giaHanHoaDon() async {
    final orderApiService = OrderApiService();

    try {
      // Gọi API updateTransactionHoaDon với hoadonId và transactionId mới
      final response = await orderApiService.updateTransactionHoaDon(
        hoadonId: widget.orderModel.id,
        transactionId: '${widget.orderModel.transactionId}',
        khuyeimaiId: '',
        giaTriGiam: 0,
      );

      // // Cập nhật UI với thông tin đơn hàng đã gia hạn
      // setState(() {
      //   widget.orderModel.transactionId = updatedOrder.transactionId;
      //   widget.orderModel.thanhToan = updatedOrder.thanhToan;
      // });

      final String paymentUrl = response.payment_url ?? '';
      print('payment url: $paymentUrl');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExprireScreen(
            orderModel: widget.orderModel,
            paymentUrl: paymentUrl,
            title: 'Gia hạn',
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gia hạn đơn hàng thành công.')),
      );
    } catch (error) {
      // Hiển thị thông báo lỗi nếu gia hạn thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gia hạn đơn hàng thất bại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

    // Determine button text and action based on status
    String buttonText = "";
    VoidCallback? buttonAction;

    if (status == 2) {
      buttonText =
          "Đánh giá đơn hàng"; // Still show the button but not clickable
      buttonAction = null;
    } else if (status <= 1) {
      buttonText = "Hủy đơn hàng";
      buttonAction = () {
        _showCancelConfirmation();
      };
    } else if (status == 3) {
      buttonText = "Đánh giá đơn hàng";
      buttonAction = () {
        // Navigator.pushNamed(context, '/oder_review_screen');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderReviewScreen(
                  title: 'Đơn hàng', id: selectedProductId!),
            ));
      };
    } else if (status == 4) {
      buttonText = "Mua lại đơn hàng";
      buttonAction = () {
        // Navigator.pushNamed(context, '/oder_review_screen');
      };
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trạng thái đơn hàng',
            style: TextStyle(
              color: Color.fromRGBO(59, 99, 53, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, true);
              },
              child: Container(
                child: const ImageIcon(
                  AssetImage('lib/assets/arrow_back.png'),
                  size: 49,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(27),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin vận chuyển',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngày giao hàng dự kiến'),
                      Text('02-10-2023'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mã đơn hàng'),
                      Text(widget.orderModel.id),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                const Text(
                  'Địa chỉ nhận hàng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Display shipping address information if available
                Text('${widget.orderModel.diaChi.name}'),
                Text('${widget.orderModel.diaChi.soDienThoai}'),
                Text(
                    '${widget.orderModel.diaChi.duongThon}, ${widget.orderModel.diaChi.phuongXa}, ${widget.orderModel.diaChi.tinhThanhPho}'),

                Row(
                  children: [
                    buildPaymentMethodsList(),
                    if (showExprireButton)
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExprireScreen(
                                      title: 'Gia hạn',
                                      orderModel: widget.orderModel,
                                      paymentUrl:
                                          widget.orderModel.payment_url),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(59, 99, 53, 1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(13),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Thanh toán'), // Button text
                          ),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: FutureBuilder<OrderModelForHoKinhDoanh>(
                    future: _orderFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Lỗi: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final order = snapshot.data!;
                        if (order.chiTietHoaDon == null ||
                            order.chiTietHoaDon!.isEmpty) {
                          return const Center(
                            child: Text(
                              'Không có sản phẩm trong hóa đơn.',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.chiTietHoaDon!.length,
                          itemBuilder: (context, index) {
                            final detail = order.chiTietHoaDon![index];
                            final bienThe = detail.bienThe;

                          // Lưu ID sản phẩm mà không gọi setState
        if (bienThe?.idSanPham.id != null) {
          selectedProductId = bienThe!.idSanPham.id; // Không dùng setState
        }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: bienThe?.idSanPham.imageProduct !=
                                              null
                                          ? Image.network(
                                              bienThe!.idSanPham.imageProduct,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                    ),
                                    const SizedBox(width: 12.0),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bienThe?.idSanPham.nameProduct ??
                                                'N/A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Giá: ${currencyFormatter.format(detail.donGia)}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            'Số lượng: ${detail.soLuong}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          if (bienThe?.ketHopThuocTinh
                                                  .isNotEmpty ??
                                              false)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                'Biến thể: ${bienThe?.ketHopThuocTinh.map((e) => e.giaTriThuocTinh.giaTri).join(", ")}',
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Total
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Tổng:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          currencyFormatter.format(
                                              detail.soLuong * detail.donGia),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Không tìm thấy dữ liệu.',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 15),
                const Text(
                  'Tình trạng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Column(
                        children: List.generate(4, (index) {
                          return Column(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: _getColor(index),
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white),
                              ),
                              if (index < 3)
                                Container(
                                  height: 60,
                                  width: 6,
                                  color: _getColor(index + 1),
                                ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusLabel('Đặt hàng', '02-10-2023'),
                          SizedBox(height: 55),
                          _StatusLabel('Đóng gói', '02-10-2023'),
                          SizedBox(height: 55),
                          _StatusLabel('Bắt đầu giao', '02-10-2023'),
                          SizedBox(height: 55),
                          _StatusLabel('Hoàn thành đơn hàng', '02-10-2023'),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset('lib/assets/ic_oder.png'),
                            const SizedBox(height: 55),
                            Image.asset('lib/assets/ic_pack.png'),
                            const SizedBox(height: 55),
                            Image.asset('lib/assets/ic_delivery.png'),
                            const SizedBox(height: 55),
                            Image.asset('lib/assets/ic_successoder.png'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Display "Cancel Order" or "Review Product" button based on status
                Center(
                  child: buttonText.isNotEmpty
                      ? ElevatedButton(
                          onPressed: buttonAction,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey; // Color when disabled
                                }
                                return const Color.fromRGBO(
                                    59, 99, 53, 1); // Normal color
                              },
                            ),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.white),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.all(13),
                            ),
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          child: Text(buttonText),
                        )
                      : const SizedBox
                          .shrink(), // Do not display button if not needed
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPaymentMethod({
    required String assetPath,
    required String title,
    String? subtitle,
    required String value,
  }) {
    return Expanded(
      flex: 2,
      child: SizedBox(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Image.asset(assetPath, width: 40, height: 40),
            title: Text(title),
            subtitle: subtitle != null
                ? Text(subtitle, style: const TextStyle(fontSize: 12))
                : null,
          ),
        ),
      ),
    );
  }

  Widget buildPaymentMethodsList() {
    if (widget.orderModel.transactionId == 111) {
      return buildPaymentMethod(
        assetPath: 'lib/assets/ic_money.png',
        title: 'Giao hàng thu tiền (COD)',
        subtitle: 'Thu bằng tiền mặt',
        value: 'COD',
      );
    } else if (widget.orderModel.transactionId == 0) {
      return const Text(
          'Bạn chưa chọn phương thức thanh toán cho đơn hàng này');
    } else {
      return buildPaymentMethod(
        assetPath: 'lib/assets/Baokim-logo.png',
        title: 'Bảo Kim',
        subtitle: 'Chuyển tiền nhanh chóng',
        value: 'Qr',
      );
    }
  }

  // Show cancel order confirmation dialog
  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đơn hàng'),
          content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                // Perform order cancellation
                _cancelOrder();
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }

  void _cancelOrder() async {
    final orderApiService =
        OrderApiService(); // Create an instance of your API service

    try {
      await orderApiService
          .cancelOrder(widget.orderModel.id); // Call cancel API

      // Update UI to reflect cancellation
      setState(() {
        status = 4; // Or any other value indicating the order is canceled
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được hủy.')),
      );

      // Optionally navigate back or refresh order status
      Navigator.pop(context); // Pop current screen if necessary
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hủy đơn hàng thất bại.')),
      );
    }
  }
}

class _StatusLabel extends StatelessWidget {
  final String title;
  final String date;

  const _StatusLabel(this.title, this.date, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        Text(
          date,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
