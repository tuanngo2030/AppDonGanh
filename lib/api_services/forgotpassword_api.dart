import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // Import SharedPreferences

class ForgotpasswordApi {

  // Helper method to get the resetToken from SharedPreferences
  Future<String?> _getResetToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('resetToken');
  }

  // Gửi OTP
  static Future<void> sendOtpForgotPassword(String gmail) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/user/SendOtpForgotPassword');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'gmail': gmail}),
      );

      if (response.statusCode == 200) {
        print('OTP sent successfully');
        // Xử lý phản hồi thành công
      } else {
        print('Failed to send OTP: ${response.statusCode}');
        // Xử lý phản hồi thất bại
      }
    } catch (error) {
      print('Error sending OTP: $error');
      // Xử lý lỗi khi gửi yêu cầu
    }
  }

  Future<bool> CheckOtpForgotPassword(String otp, String gmail) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/user/CheckOtpForgotPassword');
  
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': otp,
          'gmail': gmail,
        }),
      );

      if (response.statusCode == 200) {
        // Giải mã JSON từ phản hồi API
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Kiểm tra nếu message là 'otp đã được kiểm tra thành công'
        if (responseBody['message'] == 'otp đã được kiểm tra thành công') {
          String resetToken = responseBody['resetToken'];
          
          // Lưu resetToken vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('resetToken', resetToken);

          print('OTP verification successful. Reset token saved: $resetToken');
          return true;
        } else {
          return false; // OTP không hợp lệ
        }
      } else {
        print('Failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      return false;
    }
  }

  // Send the new password with reset token in the header
  static Future<void> sendNewPassword(String gmail, String matKhauMoi) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/user/SendPassword');
    final resetToken = await ForgotpasswordApi()._getResetToken(); // Get reset token

    if (resetToken == null) {
      print('No reset token found.');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resetToken', // Add reset token to header
        },
        body: jsonEncode({
          'gmail': gmail,
          'matKhauMoi': matKhauMoi,
        }),
      );

      if (response.statusCode == 200) {
        print('Password updated successfully');
        // Xử lý phản hồi thành công
      } else {
        print('Failed to update password: ${response.statusCode}');
        // Xử lý phản hồi thất bại
      }
    } catch (error) {
      print('Error sending new password: $error');
      // Xử lý lỗi khi gửi yêu cầu
    }
  }

  // Lưu token vào SharedPreferences
  Future<void> saveResetToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('resetToken', token);
  }

  // Lấy token từ SharedPreferences
  Future<String?> getResetToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('resetToken');
  }

  // Ví dụ sử dụng resetToken
  void someFunction() async {
    String? resetToken = await getResetToken();
    if (resetToken != null) {
      print('Token retrieved: $resetToken');
    } else {
      print('No token found.');
    }
  }
}
