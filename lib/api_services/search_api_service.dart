import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Helper function to get the token from SharedPreferences
Future<String?> _getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // Assuming the token is stored under the key 'token'
}

Future<List<dynamic>> searchSanPham(String tenSanPham, {required String userId, required String yeuthichId}) async {
  final token = await _getTokenFromSharedPreferences();
  final uri = Uri.parse('${dotenv.env['API_URL']}/sanpham/searchSanPham?TenSanPham=$tenSanPham&userId=$userId&yeuThichId=$yeuthichId');

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token to the headers
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> sanphams = json.decode(response.body);
      print(sanphams);
      return sanphams;
    } else {
      throw Exception("Failed to load products");
    }
  } catch (e) {
    print("Error: $e");
    throw Exception("Failed to connect to the server");
  }
}
