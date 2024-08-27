import 'dart:convert';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:http/http.dart' as http;

class CartApiService {
  final String url = 'https://imp-model-widely.ngrok-free.app/api/cart/gioHang/user/66c45d3b1ee5471012d0540c';

  Future<CartModel> getCart() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Giải mã JSON thành một đối tượng Map<String, dynamic>.
      Map<String, dynamic> cartData = json.decode(response.body);
      
      // Chuyển đổi JSON thành CartModel.
      return CartModel.fromJSON(cartData);
    } else {
      throw Exception('Failed to load cart');
    }
  }
}