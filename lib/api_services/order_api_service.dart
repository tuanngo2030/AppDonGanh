import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderApiService {
  final String baseUrl = "https://imp-model-widely.ngrok-free.app/api/hoadon/getHoaDonByUserId/66e29eef4957e0380722e081";

  Future<List<OrderModel>> fetchOrder() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      try {
        // In ra toàn bộ phản hồi để kiểm tra
        print('Response body: ${response.body}');
        
        // Giải mã JSON nhận được
        List<dynamic> orderDataList = json.decode(response.body);

        // Kiểm tra nếu dữ liệu không phải là một mảng
        if (orderDataList is! List) {
          throw Exception('Invalid data format: Expected a list');
        }

        // Chuyển đổi mảng JSON thành danh sách OrderModel
        return orderDataList.map((data) => OrderModel.fromJson(data)).toList();
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      // Nếu gặp lỗi, ném ra ngoại lệ.
      throw Exception('Failed to load order');
    }
  }

   
  // Hàm tạo hóa đơn
  Future<OrderModel> createUserDiaChivaThongTinGiaoHang({
    required String userId,
    required String diaChiMoi,
    required String ghiChu,
    String? khuyenmaiId,
    required String giohangId,
    required double TongTien,
    required String transactionId,
    required List<Map<String, dynamic>> ChiTietGioHang, // Thêm chi tiết giỏ hàng
    required String YeuCauNhanHang, // Thêm yêu cầu nhận hàng
  }) async {
    final String url = "https://imp-model-widely.ngrok-free.app/api/hoadon/createUserDiaChivaThongTinGiaoHang";

    final Map<String, dynamic> body = {
      'userId': userId,
      'diaChiMoi': diaChiMoi,
      'ghiChu': ghiChu,
      'khuyenmaiId': khuyenmaiId,
      'ChiTietGioHang': ChiTietGioHang,
      'YeuCauNhanHang': YeuCauNhanHang,
      'giohangId': giohangId,
      'TongTien': TongTien,
      'transactionId': transactionId,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      try {
        final data = json.decode(response.body);
        print('Create HoaDon Response: $data');
        return OrderModel.fromJson(data);
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      print('Failed to create HoaDon: ${response.body}');
      throw Exception('Failed to create HoaDon');
    }
  }
}
