import 'dart:convert';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://peacock-wealthy-vaguely.ngrok-free.app/api/user/Register';

  // Đăng ký người dùng mới
  Future<bool> registerUser(NguoiDung user) async {
    final response = await http.post(
      Uri.parse('$_baseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'tenNguoiDung': user.tenNguoiDung,
        'gmail': user.gmail,
        'matKhau': user.matKhau,
        'otp': user.otp,  
      }),
    );

    if (response.statusCode == 200) {
      // Đăng ký thành công
      return true;
    } else {
      // Đăng ký thất bại
      print('Failed to register user: ${response.body}');
      return false;
    }
  }

  // Đăng nhập người dùng
  Future<NguoiDung?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Đăng nhập thành công, parse JSON response để lấy thông tin người dùng
      return NguoiDung.fromJson(jsonDecode(response.body));
    } else {
      // Đăng nhập thất bại
      print('Failed to login: ${response.body}');
      return null;
    }
  }
}
