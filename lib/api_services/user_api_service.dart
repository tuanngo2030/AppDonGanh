import 'dart:convert';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart'; // Thêm thư viện này để giải mã token

class UserApiService {
  final String baseUrl = 'https://imp-model-widely.ngrok-free.app/api/user/login';
  final String baseUrlid = 'https://imp-model-widely.ngrok-free.app/api/user/showUserID';

  Future<NguoiDung?> login(String gmail, String matKhau) async {
    final uri = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'gmail': gmail,
          'matKhau': matKhau,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Response from API: $data');

        // Lấy token từ phản hồi API
        String? token = data['token']; // Giả sử token được trả về ở đây

        if (token != null) {
          // Giải mã token để lấy userId
          Map<String, dynamic> payload = Jwt.parseJwt(token);
          String? userId = payload['data']; // userId thường nằm trong payload

          if (userId != null) {
            // Lấy thông tin người dùng theo ID
            NguoiDung? user = await fetchUserDetails(userId);
            if (user != null) {
              // Lưu thông tin người dùng và token vào SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('tenNguoiDung', user.tenNguoiDung ?? '');
              await prefs.setString('userId', userId);
              await prefs.setString('token', token); // Lưu token để dùng sau
              return user;
            }
          }
        }
      } else {
        print('Failed to login: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }

    return null;
  }

  Future<NguoiDung?> fetchUserDetails(String userId) async {
    final uri = Uri.parse('$baseUrlid/$userId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('User details: $data');
        return NguoiDung.fromJson(data);
      } else {
        print('Failed to fetch user details: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
