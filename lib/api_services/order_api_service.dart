import 'package:don_ganh_app/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderApiService{
  final String baseUrl = "https://imp-model-widely.ngrok-free.app/api/hoadon/getHoaDonById/66e29eef4957e0380722e081";


  Future<OrderModel> fetchOrder() async {
    final response = await http.get(Uri.parse(baseUrl));
    
    if (response.statusCode == 200) {
      // Nếu trả về thành công, chuyển đổi dữ liệu JSON thành OrderModel
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      // Nếu gặp lỗi, ném ra ngoại lệ.
      throw Exception('Failed to load order');
    }
}
}