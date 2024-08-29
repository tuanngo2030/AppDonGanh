import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpApiService {
  static const String baseUrl = 'https://imp-model-widely.ngrok-free.app/api/user/verifyOtp';
   static const String resendUrl= 'https://imp-model-widely.ngrok-free.app/api/user/resendOTP';

  // Phương thức xác minh OTP
  Future<bool> verifyOtp(String otp, String gmail) async {
    try {
      Map<String, dynamic> requestData = {
        'gmail': gmail,
        'otp': otp,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Request Data: ${jsonEncode(requestData)}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response from API: $responseData');

        if (responseData['message'] == 'Xác nhận OTP thành công, tài khoản đã được kích hoạt') {
          print('OTP verification successful.');
          return true;
        } else {
          print('OTP verification failed.');
          return false;
        }
      } else {
        print('Failed to verify OTP: ${response.statusCode}');
        print('Error Details: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Phương thức gửi lại OTP
  Future<bool> resendOtp(String gmail) async {
    try {
      Map<String, dynamic> requestData = {
        'gmail': gmail,
      };

      final response = await http.post(
        Uri.parse(resendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Request Data: ${jsonEncode(requestData)}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response from API: $responseData');

        if (responseData['message'] == 'Mã OTP đã được gửi lại thành công') {
          print('OTP resend successful.');
          return true;
        } else {
          print('OTP resend failed.');
          return false;
        }
      } else {
        print('Failed to resend OTP: ${response.statusCode}');
        print('Error Details: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error resending OTP: $e');
      return false;
    }
  }
}
