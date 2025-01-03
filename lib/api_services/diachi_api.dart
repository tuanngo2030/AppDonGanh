import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaChiApiService {
  final String baseUrl = '${dotenv.env['API_URL']}/diachi';

  // Helper method to get the token from SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Lấy danh sách địa chỉ theo userId
  Future<List<diaChiList>> getDiaChiByUserId(String userId) async {
    final uri = Uri.parse('$baseUrl/getDiaChiByUserId/$userId');
    final token = await _getToken();

    print('Fetching addresses for userId: $userId'); // In ra userId

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // In ra phản hồi

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Decoded response: $data'); // In ra phản hồi đã được giải mã

        // Kiểm tra xem có thông tin địa chỉ hay không
        if (data.containsKey('diaChiList') && data['diaChiList'] is List) {
          List<dynamic> addressesJson = data['diaChiList'];

          // Lọc địa chỉ chưa bị đánh dấu xóa
          List<diaChiList> addresses = addressesJson
              .map((item) => diaChiList.fromJson(item))
              .toList();

          if (addresses.isNotEmpty) {
            return addresses;
          } else {
            print('Addresses list is empty');
            return [];
          }
        } else {
          print('No diaChiList key found in response or it is not a list');
          return [];
        }
      } else {
        print('Failed to fetch addresses: ${response.statusCode}, Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // Tạo địa chỉ mới cho userId
  Future<bool> createDiaChi(String userId, diaChiList diaChi) async {
    final uri = Uri.parse('$baseUrl/createDiaChi/$userId');
    final token = await _getToken();

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(diaChi.toJson()),
      );

      if (response.statusCode == 200) {
        print('Address created successfully');
        return true;
      } else {
        print('Failed to create address. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error creating address: $e');
      return false;
    }
  }

  // Cập nhật địa chỉ cho userId và diaChiId
  Future<bool> updateDiaChi(
      String userId, String diaChiId, diaChiList diaChi) async {
    final uri = Uri.parse('$baseUrl/updateDiaChi/$userId/$diaChiId');
    final token = await _getToken();

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(diaChi.toJson()),
      );

      if (response.statusCode == 200) {
        print('Address updated successfully');
        return true;
      } else {
        print('Failed to update address. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  // Xóa địa chỉ theo userId và diaChiId
  Future<bool> deleteDiaChi(String userId, String diaChiId) async {
    final uri = Uri.parse('$baseUrl/deleteDiaChi/$userId/$diaChiId');
    final token = await _getToken();

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Address deleted successfully');
        return true;
      } else {
        print('Failed to delete address. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }
}
