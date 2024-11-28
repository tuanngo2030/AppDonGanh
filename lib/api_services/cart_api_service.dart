import 'dart:convert';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartApiService {
  final String baseUrl = '${dotenv.env['API_URL']}/cart/gioHang/user/';

Future<List<CartModel>> getGioHangByUserId() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final String url = '$baseUrl$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Response Data Cart: $responseData');

      // Trả về toàn bộ dữ liệu nếu không có mergedCart riêng biệt
      if (responseData != null) {
        // Nếu dữ liệu là một danh sách (List) hoặc đối tượng (Map)
        if (responseData is List) {
          return responseData
              .map((cartData) => CartModel.fromJSON(cartData as Map<String, dynamic>))
              .toList();
        } else if (responseData is Map) {
          // Nếu trả về một object, cần lấy các trường cần thiết như mergedCart, user, v.v.
          // Explicitly cast the responseData to Map<String, dynamic>
          Map<String, dynamic> castedData = Map<String, dynamic>.from(responseData);

          return [
            CartModel.fromJSON(castedData), // Chuyển đổi toàn bộ dữ liệu thành CartModel
          ];
        } else {
          throw Exception('Expected responseData to be a list or map, but got: ${responseData.runtimeType}');
        }
      } else {
        throw Exception('No data found in response');
      }
    } else {
      throw Exception('Failed to load cart. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching cart data: $error');
    throw Exception('Error fetching cart data');
  }
}


  Future<CartModel> addToCart(
      String userId, String idBienThe, int quantity, int donGia) async {
    final addToCartURL = '${dotenv.env['API_URL']}/cart/gioHang?';

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

    try {
      final response = await http.post(
        Uri.parse(addToCartURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          Map<String, dynamic> cartData = json.decode(response.body);
          print('Decoded Cart Data: $cartData');
          return CartModel.fromJSON(cartData);
        } catch (e) {
          print('Error decoding JSON: $e');
          throw Exception('Failed to decode JSON');
        }
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to add to cart');
      }
    } catch (e, stackTrace) {
      print('HTTP Request Error: $e');
      print('StackTrace: $stackTrace');
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> deleteFromCart(String idGioHang, String idBienThe) async {
    final deleteFromCartURL =
        '${dotenv.env['API_URL']}/cart/gioHang/$idGioHang';

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

  Future<void> updateCart(
      String idGioHang, String idBienThe, int soLuong, int donGia, String idChitietgiohang) async {
    final updateCartURL = '${dotenv.env['API_URL']}/cart/gioHang/$idGioHang';

    Map<String, dynamic> requestBody = {
      'chiTietGioHang': [
        {
          '_id' : idChitietgiohang,
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
