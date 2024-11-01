import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> searchSanPham(String tenSanPham) async {
  final uri = Uri.parse('${dotenv.env['API_URL']}/sanpham/searchSanPham?TenSanPham=$tenSanPham');
  try {
    final response = await http.get(uri);

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