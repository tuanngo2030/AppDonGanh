// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DcApiService {
//   static const String baseUrl = 'https://provinces.open-api.vn/api';

//   // Lấy danh sách Tỉnh/Thành phố
//   Future<List<String>> getTinhThanhPho() async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/p/'),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
//       return data.map((item) => item['name'] as String).toList();
//     } else {
//       throw Exception('Failed to load provinces');
//     }
//   }

// // Chỉ lấy danh sách Quận/Huyện
// Future<List<String>> getQuanHuyen() async {
//   final response = await http.get(
//     Uri.parse('$baseUrl/d/'), // Đảm bảo rằng API trả về tất cả quận/huyện
//     headers: {
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//   );

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
//     return data.map((item) => item['name'] as String).toList();
//   } else {
//     throw Exception('Failed to load districts');
//   }
// }

// // Chỉ lấy danh sách Phường/Xã
// Future<List<String>> getPhuongXa() async {
//   final response = await http.get(
//     Uri.parse('$baseUrl/w/'), // Đảm bảo rằng API trả về tất cả phường/xã
//     headers: {
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//   );

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
//     return data.map((item) => item['name'] as String).toList();
//   } else {
//     throw Exception('Failed to load wards');
//   }
// }

// }
import 'package:http/http.dart' as http;
import 'dart:convert';

class DcApiService {
  static const String baseUrl = 'https://provinces.open-api.vn/api';

  // Lấy danh sách Tỉnh/Thành phố
  Future<List<dynamic>> getTinhThanhPho() async {
    final response = await http.get(
      Uri.parse('$baseUrl/p/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  // Lấy danh sách Quận/Huyện theo mã Tỉnh/Thành phố
  Future<List<dynamic>> getQuanHuyen(String cityCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/p/$cityCode?depth=2'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['districts'];
    } else {
      throw Exception('Failed to load districts');
    }
  }

  // Lấy danh sách Phường/Xã theo mã Quận/Huyện
  Future<List<dynamic>> getPhuongXa(String districtCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/d/$districtCode?depth=2'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['wards'];
    } else {
      throw Exception('Failed to load wards');
    }
  }
}
