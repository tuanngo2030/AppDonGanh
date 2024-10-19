import 'dart:convert';
import 'package:http/http.dart' as http;

class dcApiService {
  final String baseUrl = 'https://open.oapi.vn/location';

  // Lấy danh sách tỉnh/thành phố
  Future<List<String>> getProvinces() async {
    final response = await http.get(Uri.parse('$baseUrl/provinces'));

    if (response.statusCode == 200) {
      print('Provinces response: ${utf8.decode(response.bodyBytes)}');
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes))['data']; // Lấy 'data' từ JSON
      
      // Kiểm tra nếu data trả về không phải là List
      if (data is List) {
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  // Lấy danh sách quận/huyện dựa trên mã tỉnh/thành phố
  Future<List<String>> getDistricts(String provinceCode) async {
    final String url = '$baseUrl/districts?province=$provinceCode';
    print('Fetching districts from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes))['data'];
      
      if (data is List) {
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load districts');
    }
  }

  // Lấy danh sách phường/xã dựa trên mã quận/huyện
  Future<List<String>> getWards(String districtCode) async {
    final String url = '$baseUrl/wards?district=$districtCode';
    print('Fetching wards from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes))['data'];
      
      if (data is List) {
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load wards');
    }
  }
}
