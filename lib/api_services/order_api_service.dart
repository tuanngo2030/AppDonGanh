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
}
