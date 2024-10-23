import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordApi {
  final String _resetPasswordUrl =
      'https://peacock-wealthy-vaguely.ngrok-free.app/api/user/ResetPassword';

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(_resetPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'gmail': email,
          'matKhauMoi': newPassword,
        }),
      );

      return response.statusCode == 200; // Trả về true nếu thành công
    } catch (e) {
      return false; // Trả về false nếu có lỗi xảy ra
    }
  }
}