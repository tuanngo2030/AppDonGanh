import 'dart:convert';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart'; // For decoding JWT tokens

class UserApiService {
  final String baseUrl =
      'https://imp-model-widely.ngrok-free.app/api/user/login';
  final String baseUrlid =
      'https://imp-model-widely.ngrok-free.app/api/user/showUserID';

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

        // Get token from API response
        String? token = data['token'];

        if (token != null) {
          // Decode token to get userId
          Map<String, dynamic> payload = Jwt.parseJwt(token);
          String? userId = payload['data'];

          if (userId != null) {
            // Fetch user details by userId
            NguoiDung? user = await fetchUserDetails(userId);
            if (user != null) {
              // Save user information and token in SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('id', user.id ?? '');
              await prefs.setString('anhDaiDien', user.anhDaiDien ?? '');
              await prefs.setString('tenNguoiDung', user.tenNguoiDung ?? '');
              await prefs.setInt('soDienThoai', user.soDienThoai ?? 0);
              await prefs.setString('gmail', user.gmail ?? '');
              await prefs.setString('GioiTinh', user.GioiTinh ?? '');
              await prefs.setString('ngaySinh', user.ngaySinh ?? '');
              await prefs.setBool('hoKinhDoanh', user.hoKinhDoanh ?? false);
              String diaChi = jsonEncode(user.diaChi?.toJson() ?? {});
              await prefs.setString('diaChi', diaChi);
              await prefs.setString('tinhTrang', user.tinhTrang ?? '');
              await prefs.setStringList(
                  'phuongThucThanhToan', user.phuongThucThanhToan ?? []);
              await prefs.setString('role', user.role ?? 'user');
              await prefs.setBool('isVerified', user.isVerified ?? false);
              await prefs.setString('googleId', user.googleId ?? '');
              await prefs.setString('facebookId', user.facebookId ?? '');
              await prefs.setString('userId', user.id ?? '');
              await prefs.setString('token', token);
              return user;
            }
          }
        }
      } else {
        print('Failed to login: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
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
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }
}
