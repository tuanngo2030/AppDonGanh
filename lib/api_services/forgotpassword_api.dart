import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // Import SharedPreferences

class ForgotpasswordApi {
  
  // Gửi OTP
  static Future<void> sendOtpForgotPassword(String gmail) async {
    final url = Uri.parse('https://imp-model-widely.ngrok-free.app/api/user/SendOtpForgotPassword');

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
  final url = Uri.parse('https://imp-model-widely.ngrok-free.app/api/user/CheckOtpForgotPassword');
  
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

 static Future<void> sendNewPassword(String gmail, String matKhauMoi, String resetToken) async {
    final url = Uri.parse('https://imp-model-widely.ngrok-free.app/api/user/SendPassword');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'gmail': gmail,
          'matKhauMoi': matKhauMoi,
          'resetToken': resetToken,
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
