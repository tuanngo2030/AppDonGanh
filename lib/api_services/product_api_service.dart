import 'dart:convert';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductApiService {
  final String apiUrl = "${dotenv.env['API_URL']}/sanpham";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Retrieve token from SharedPreferences
  }

  Future<List<ProductModel>> getListProduct() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/getlistSanPham'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> productResponse = json.decode(response.body);
      return productResponse
          .map((json) => ProductModel.fromJSON(json))
          .toList();
    } else {
      throw Exception("Failed to load product list");
    }
  }

  Future<ProductModel> getProductByID(String productID) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/getDatabientheByid/$productID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var productResponse = json.decode(response.body);
      return ProductModel.fromJSON(productResponse);
    } else {
      throw Exception("Failed to load product details");
    }
  }

  Future<Map<String, dynamic>> getVariantById(String idbienthe) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/getDatabientheByid/$idbienthe'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load variant');
    }
  }

  Future<Map<String, dynamic>> getProducts(int page,
      {int limit = 6, required String userId, required String yeuthichId}) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}/sanpham/getlistPageSanPham/$page?limit=$limit&userId=$userId&yeuThichId=$yeuthichId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
