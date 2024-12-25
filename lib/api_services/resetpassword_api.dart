import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordApi {
  final String _resetPasswordUrl =
      '${dotenv.env['API_URL']}/user/ResetPassword'; 

  // Phương thức lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Giả sử bạn lưu token với khóa 'token'
  }

  // Phương thức reset mật khẩu
  Future<bool> resetPassword(
      String email, String matKhau, String newPassword) async {
    try {
      String? token = await _getToken(); // Lấy token từ SharedPreferences
      if (token == null) {
        print('Token not found');
        return false; // Nếu không có token thì trả về false
      }

      final response = await http.post(
        Uri.parse(_resetPasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
        body: json.encode({
          'gmail': email,
          'matKhau': matKhau,
          'matKhauMoi': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Nếu yêu cầu thành công, trả về true
        return true;
      } else {
        // Xử lý lỗi từ API
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        print('Error: ${errorResponse['message']}'); // Log thông báo lỗi
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false; // Trả về false nếu có ngoại lệ xảy ra
    }
  }
}
