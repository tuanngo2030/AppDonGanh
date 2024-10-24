import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginWithApiGoogle {
  Future<void> registerUserGoogle(
    String displayName, String email, String googleId) async {
  final url =
      '${dotenv.env['API_URL']}/user/RegisterUserGG';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tenNguoiDung': displayName,
        'gmail': email,
        'googleId': googleId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('User registered successfully: $data');

      // Giả sử token có trong phần dữ liệu trả về
      String? token = data['token']; // Thay đổi key nếu khác
      print('Token: $token'); // In ra token

      // Giải mã token để lấy thông tin người dùng
      if (token != null) {
        Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
        String userId = decodedToken['data']['_id']; // Lấy _id từ decodedToken
        print('User ID: $userId'); // In ra userId

        // Lưu userId vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        print("User ID saved to SharedPreferences successfully.");
      }
    } else {
      throw Exception('Failed to register user');
    }
  } catch (error) {
    throw Exception('Error occurred while registering user: $error');
  }
}

  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() async {
    return await _googleSignIn.signIn();
  }

  static Future<void> logout() async {
    await _googleSignIn.disconnect();
  }

  // Thêm hàm này để lấy thông tin người dùng sau khi đăng nhập Google
  Future<NguoiDung?> fetchUserDetails(String userId) async {
    final uri = Uri.parse('${dotenv.env['API_URL']}/user/showUserID');

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
