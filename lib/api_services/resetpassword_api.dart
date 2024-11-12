import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordApi {
  final String _resetPasswordUrl =
      '${dotenv.env['API_URL']}/user/ResetPassword'; 
  Future<bool> resetPassword(
      String email, String matKhau, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(_resetPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'gmail': email,
          'matKhau': matKhau,
          'matKhauMoi': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // If response is successful, return true
        return true;
      } else {
        // Handle API errors
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        print('Error: ${errorResponse['message']}'); // Log the error message
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false; // Return false if an exception occurs
    }
  }
}
