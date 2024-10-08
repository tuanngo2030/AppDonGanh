import 'dart:convert';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartApiService {
  final String baseUrl = 'https://imp-model-widely.ngrok-free.app/api/cart/gioHang/user/';

  Future<CartModel> getCart() async {
    // Retrieve userId from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final String url = '$baseUrl$userId'; // Construct the URL with dynamic userId

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Print received data

      try {
        Map<String, dynamic> cartData = json.decode(response.body);
        // Convert JSON to CartModel
        return CartModel.fromJSON(cartData);
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    }
     else {
      print('Response body: ${response.body}');
      throw Exception('Failed to load cart');
    }
  }

  Future<CartModel> addToCart(
      String userId, String idBienThe, int quantity, int donGia) async {
    final addToCartURL =
        'https://imp-model-widely.ngrok-free.app/api/cart/gioHang?';

    Map<String, dynamic> data = {
      'userId': userId,
      'chiTietGioHang': [
        {
          'idBienThe': idBienThe,
          'soLuong': quantity,
          'donGia': donGia,
        }
      ]
    };

    final response = await http.post(
      Uri.parse(addToCartURL),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> cartData = json.decode(response.body);
      return CartModel.fromJSON(cartData);
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> deleteFromCart(String idGioHang, String idBienThe) async {
    final deleteFromCartURL =
        'https://imp-model-widely.ngrok-free.app/api/cart/gioHang/$idGioHang';

    Map<String, dynamic> requestBody = {
      'idBienThe': idBienThe,
    };

    final response = await http.delete(
      Uri.parse(deleteFromCartURL),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Delete from cart successfully');
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to delete from cart');
    }
  }

  Future<void> updateCart(String idGioHang, String idBienThe, int soLuong, int donGia) async {
    final updateCartURL = 'https://imp-model-widely.ngrok-free.app/api/cart/gioHang/$idGioHang';

    Map<String, dynamic> requestBody = {
      'chiTietGioHang': [
        {
          'idBienThe': idBienThe,
          'soLuong': soLuong,
          'donGia': donGia,
        }
      ]
    };

    final response = await http.put(
      Uri.parse(updateCartURL),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Update cart successfully');
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to update cart');
    }
  }
}
