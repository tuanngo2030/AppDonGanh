import 'dart:convert';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartApiService {
  final String baseUrl = '${dotenv.env['API_URL']}/cart/gioHang/user/';

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }
    return token;
  }

  Future<List<CartModel>> getGioHangByUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      String token = await _getToken();
      final String url = '$baseUrl$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data Cart: $responseData');

        if (responseData != null) {
          if (responseData is List) {
            return responseData
                .map((cartData) =>
                    CartModel.fromJSON(cartData as Map<String, dynamic>))
                .toList();
          } else if (responseData is Map) {
            Map<String, dynamic> castedData =
                Map<String, dynamic>.from(responseData);
            return [CartModel.fromJSON(castedData)];
          } else {
            throw Exception(
                'Expected responseData to be a list or map, but got: ${responseData.runtimeType}');
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

    String token = await _getToken();

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
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> cartData = json.decode(response.body);
      return CartModel.fromJSON(cartData);
    } else {
      print('Error Response: ${response.body}');
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> deleteFromCart(String idGioHang, String idBienThe) async {
    final deleteFromCartURL =
        '${dotenv.env['API_URL']}/cart/gioHang/$idGioHang';

    String token = await _getToken();

    Map<String, dynamic> requestBody = {
      'idBienThe': idBienThe,
    };

    final response = await http.delete(
      Uri.parse(deleteFromCartURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
      throw Exception('Failed to delete from cart');
    }
  }

  Future<void> updateCart(String idGioHang, String idBienThe, int soLuong,
      int donGia, String idChitietgiohang) async {
    final updateCartURL = '${dotenv.env['API_URL']}/cart/gioHang/$idGioHang';

    String token = await _getToken();

    Map<String, dynamic> requestBody = {
      'chiTietGioHang': [
        {
          '_id': idChitietgiohang,
          'idBienThe': idBienThe,
          'soLuong': soLuong,
          'donGia': donGia,
        }
      ]
    };

    final response = await http.put(
      Uri.parse(updateCartURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
      throw Exception('Failed to update cart');
    }
  }
}
