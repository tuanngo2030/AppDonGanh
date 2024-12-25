import 'dart:convert';
import 'package:don_ganh_app/models/variant_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Helper function to get the token from SharedPreferences
Future<String?> _getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // Assuming the token is stored under the key 'token'
}

class VariantApiService {
  final String url = "${dotenv.env['API_URL']}/sanpham/getlistBienThe/";

  Future<List<VariantModel>> getVariant(String idProduct) async {
    final token = await _getTokenFromSharedPreferences();
    final response = await http.get(
      Uri.parse('$url$idProduct'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token to the headers
      },
    );

    if (response.statusCode == 200) {
      List variant = json.decode(response.body);
      return variant.map((variant) => VariantModel.fromJSON(variant)).toList();
    } else {
      throw Exception('Failed to load variants');
    }
  }
}
