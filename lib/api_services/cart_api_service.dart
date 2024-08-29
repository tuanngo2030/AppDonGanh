import 'dart:convert';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:http/http.dart' as http;

class CartApiService {
  final String url = 'https://imp-model-widely.ngrok-free.app/api/cart/gioHang/user/66c45d3b1ee5471012d0540c';

 Future<CartModel> getCart() async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    print('Response body: ${response.body}'); // In ra dữ liệu nhận được

    // Giải mã JSON thành một đối tượng Map<String, dynamic>.
    try {
      Map<String, dynamic> cartData = json.decode(response.body);
      // Chuyển đổi JSON thành CartModel.
      return CartModel.fromJSON(cartData);
    } catch (e) {
      print('Error decoding JSON: $e');
      throw Exception('Failed to decode JSON');
    }
  } else {
    print('Response body: ${response.body}');
    throw Exception('Failed to load cart');
  }
}

Future<CartModel> addToCart(String userId, String idBienThe, int quantity) async {
  final addToCartURL = 'https://imp-model-widely.ngrok-free.app/api/cart/gioHang?';

  Map<String,dynamic> data = {
    'userId': userId,
    'chiTietGioHang' : [
      {
        'idBienThe': idBienThe,
        'soLuong' : quantity,
      }
    ]
  };

  final response = await http.post(Uri.parse(addToCartURL));

  if(response.statusCode == 200){
     Map<String, dynamic> cartData = json.decode(response.body);
    return CartModel.fromJSON(cartData);
  }else{
    print('Response body: ${response.body}');
    throw Exception('Failed to add to cart');
  }
  

}
}