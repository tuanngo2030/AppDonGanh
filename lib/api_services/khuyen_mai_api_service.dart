import 'dart:convert';
import 'package:don_ganh_app/models/khuyen_mai_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // Import SharedPreferences

class KhuyenMaiApiService {
  
  // Helper method to get the token from SharedPreferences
  Future<String?> _getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Assuming the token is stored under 'token'
  }

  Future<List<KhuyenMaiModel>> fetchPromotionList(int tongtien) async {
    final token = await _getTokenFromSharedPreferences(); // Get token from SharedPreferences
    if (token == null) {
      throw Exception('No token found in SharedPreferences');
    }

    // Add token to the request headers
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/khuyenmai/getlistKhuyenMai/$tongtien'),
      headers: {
        'Authorization': 'Bearer $token', // Add token to headers
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => KhuyenMaiModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load promotion list');
    }
  }
}
