// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressApi {
  final String baseUrl = 'https://provinces.open-api.vn/api';

  Future<List<String>> fetchTinhThanhPho() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  Future<List<String>> fetchQuanHuyen() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/d/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  Future<List<String>> fetchPhuongXa() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/w/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception('Failed to load wards');
      }
    } catch (e) {
      throw Exception('Error fetching wards: $e');
    }
  }

}