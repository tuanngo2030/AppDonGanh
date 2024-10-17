import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OderStatusScreen extends StatefulWidget {
  final OrderModel orderModel;
  const OderStatusScreen({super.key, required this.orderModel});

  @override
  State<OderStatusScreen> createState() => _OderStatusScreenState();
}

class _OderStatusScreenState extends State<OderStatusScreen> {
  late int status;

  @override
  void initState() {
    super.initState();
    status = widget.orderModel.TrangThai; // Get status from orderModel
  }

  Color _getColor(int step) {
    return (step <= status) ? const Color.fromRGBO(41, 87, 35, 1) : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
    
    // Determine button text and action based on status
    String buttonText = "";
    VoidCallback? buttonAction;

    if (status == 2) {
      buttonText = "Đánh giá đơn hàng"; // Still show the button but not clickable
      buttonAction = null;
    } else if (status <= 1) {
      buttonText = "Hủy đơn hàng";
      buttonAction = () {
        _showCancelConfirmation();
      };
    } else if (status >= 3) {
      buttonText = "Đánh giá đơn hàng";
      buttonAction = () {
        Navigator.pushNamed(context, '/oder_review_screen');
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
                Text('${widget.orderModel.diaChi.duongThon}, ${widget.orderModel.diaChi.phuongXa}, ${widget.orderModel.diaChi.tinhThanhPho}'),
                const SizedBox(height: 20),
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
                                child: const Icon(Icons.check, color: Colors.white),
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
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey; // Color when disabled
                                }
                                return const Color.fromRGBO(59, 99, 53, 1); // Normal color
                              },
                            ),
                            foregroundColor: WidgetStateProperty.all(Colors.white),
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
                      : const SizedBox.shrink(), // Do not display button if not needed
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  // Perform order cancellation
  void _cancelOrder() {
    // TODO: Implement order cancellation logic, e.g., call API to cancel the order
    // After successful cancellation, update order status
    setState(() {
      status = -1; // Or some other value representing canceled order
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đơn hàng đã được hủy.')),
    );

    // Optionally, you can navigate the user back or refresh data
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
