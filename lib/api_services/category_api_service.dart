import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:don_ganh_app/models/categories_model.dart'; 

class CategoryApiService {
  final String apiUrl = "${dotenv.env['API_URL']}/danhmuc/getlistDanhMuc";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> categoryResponse = json.decode(response.body);
      return categoryResponse
          .map((category) => CategoryModel.fromJSON(category))
          .toList();
    } else {
      throw Exception('Failed to fetch categories');
    }
  }
}
