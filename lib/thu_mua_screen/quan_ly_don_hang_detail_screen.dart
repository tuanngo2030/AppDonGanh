import 'package:don_ganh_app/models/oder_model_for_hokinhdoanh.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:intl/intl.dart';

class QuanLyDonHangDetailScreen extends StatefulWidget {
  final String hoadonId;

  const QuanLyDonHangDetailScreen({super.key, required this.hoadonId});

  @override
  State<QuanLyDonHangDetailScreen> createState() =>
      _QuanLyDonHangDetailScreenState();
}

class _QuanLyDonHangDetailScreenState extends State<QuanLyDonHangDetailScreen> {
  late Future<OrderModelForHoKinhDoanh> _orderFuture;
  int? _selectedStatus;
    bool _isUpdating = false; 

  // List of possible statuses with readable labels
  final Map<int, String> orderStatusLabels = {
    0: "Đặt hàng",
    1: "Đóng gói",
    2: "Bắt đầu giao",
    3: "Hoàn thành đơn hàng",
    4: "Hủy",
  };

  @override
  void initState() {
    super.initState();
    _orderFuture = OrderApiService().getHoaDonByHoaDonId(widget.hoadonId);
  }

   // Function to handle status update
 Future<void> _updateStatus(int newStatus) async {
  if (newStatus == 3) {
    // Nếu trạng thái là 3, hiển thị thông báo và không thực hiện API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chỉ Admin mới có thể hoàn thành đơn hàng.'),
      ),
    );
    return; // Thoát hàm mà không gọi API
  }

  try {
    setState(() {
      _isUpdating = true; // Set updating flag to true
    });

    // Call the API to update the status
    await OrderApiService().updateOrderStatus(widget.hoadonId, newStatus);

    if (mounted) {
      setState(() {
        _selectedStatus = newStatus;
        _isUpdating = false; // Set updating flag to false after the update is complete
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trạng thái đơn hàng đã được cập nhật!')),
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isUpdating = false; // Set updating flag to false if an error occurs
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    // Create a number formatter for VND
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

    // Create a date formatter
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: FutureBuilder<OrderModelForHoKinhDoanh>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final order = snapshot.data!;

            // Set the initial selected status
            _selectedStatus ??= order.TrangThai;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Order Info
                  Text(
                    'Mã đơn hàng: ${order.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Ngày tạo: ${dateFormatter.format(order.NgayTao)}'),

                  // Status DropMenu
                  const SizedBox(height: 10),
                  const Text(
                    'Trạng thái hiện tại:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: _selectedStatus,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                    items: orderStatusLabels.entries.map<DropdownMenuItem<int>>(
                      (entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Address
                  const Text(
                    'Địa chỉ giao hàng:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Đường/Thôn: ${order.diaChi.duongThon ?? "N/A"}'),
                  const SizedBox(height: 20),

                  // Products
                  const Text(
                    'Danh sách sản phẩm:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...?order.chiTietHoaDon?.map(
                    (detail) {
                      final bienThe = detail.bienThe;
                      return ListTile(
                        leading: bienThe?.idSanPham.imageProduct != null
                            ? Image.network(
                                bienThe!.idSanPham.imageProduct,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(bienThe?.idSanPham.nameProduct ?? 'N/A'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Giá: ${currencyFormatter.format(detail.donGia)}'),
                            Text('Số lượng: ${detail.soLuong}'),
                            if (bienThe?.ketHopThuocTinh.isNotEmpty ?? false)
                              Text(
                                'Biến thể: ${bienThe?.ketHopThuocTinh.map((e) => e.giaTriThuocTinh.giaTri).join(", ")}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          'Tổng: ${currencyFormatter.format(detail.soLuong * detail.donGia)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // Discounts
                  if (order.khuyenmaiId != null)
                    ListTile(
                      title: const Text('Khuyến mãi:'),
                      trailing: Text(
                        '${order.SoTienKhuyenMai} VND',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),

                  // Total Price
                  ListTile(
                    title: const Text('Tổng tiền thanh toán:'),
                    trailing: Text(
                      currencyFormatter
                          .format(order.TongTien - order.SoTienKhuyenMai),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  // Confirm button to update status
                   // Confirm button to update status
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedStatus != null && !_isUpdating && _selectedStatus != 3
                        ? () => _updateStatus(_selectedStatus!)
                        : null,
                    child: const Text('Xác nhận thay đổi trạng thái'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Không tìm thấy dữ liệu.'),
            );
          }
        },
      ),
    );
  }
} 