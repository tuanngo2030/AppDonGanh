// diachi_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class dcApiService {
  final String baseUrl = 'https://provinces.open-api.vn/api';
Future<List<String>> getProvinces() async {
  final response = await http.get(Uri.parse('$baseUrl/p'));
  if (response.statusCode == 200) {
    print(utf8.decode(response.bodyBytes)); // In dữ liệu ra để kiểm tra
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    return data.map((item) => item['name'] as String).toList();
  } else {
    throw Exception('Failed to load provinces');
  }
}

Future<List<String>> getDistricts(String provinceCode) async {
  final String url = '$baseUrl/d';
  print('Fetching districts from: $url'); // In URL ra để kiểm tra
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));  // Đảm bảo UTF-8 decoding
    return data.map((item) => item['name'] as String).toList();
  } else {
    throw Exception('Failed to load districts');
  }
}


  Future<List<String>> getWards(String districtCode) async {
    final response = await http.get(Uri.parse('$baseUrl/w'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => item['name'] as String).toList();
    } else {
      throw Exception('Failed to load wards');
    }
  }
}
