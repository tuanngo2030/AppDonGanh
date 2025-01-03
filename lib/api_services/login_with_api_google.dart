import 'dart:io';

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
    final url = '${dotenv.env['API_URL']}/user/RegisterUserGG';

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
          String userId =
              decodedToken['data']['_id']; // Lấy _id từ decodedToken
          print('User ID: $userId'); // In ra userId

          // Lưu tất cả thông tin vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setString('token', token);

          // Lưu các thông tin khác của người dùng từ API vào SharedPreferences
          await prefs.setString('tenNguoiDung', displayName);
          await prefs.setString('gmail', email);
          await prefs.setString(
              'anhDaiDien', decodedToken['data']['anhDaiDien'] ?? '');
          await prefs.setString(
              'IDYeuThich', decodedToken['data']['IDYeuThich'] ?? '');
          List<String> followers =
              List<String>.from(decodedToken['data']['follower'] ?? []);
          List<String> following =
              List<String>.from(decodedToken['data']['following'] ?? []);

          await prefs.setStringList('follower', followers);
          await prefs.setStringList('following', following);
          await prefs.setInt(
              'soTienHienTai', decodedToken['data']['soTienHienTai'] ?? 0);
          await prefs.setString('role', decodedToken['data']['role'] ?? 'khachhang');

          print("User information saved to SharedPreferences successfully.");
        }
      } else {
        throw Exception('Failed to register user');
      }
    } catch (error) {
      print(error);
      throw Exception('Error occurred while registering user: $error');
    }
  }
  // static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // // static final GoogleSignIn _googleSignIn = GoogleSignIn(
  // //     clientId: '459872854706-6q2tk8as2nnu427otlpoprtc4vnm84oh.apps.googleusercontent.com',
  // // );

  // static Future<GoogleSignInAccount?> login() async {
  //   await _googleSignIn.signOut();
  //   return await _googleSignIn.signIn();
  // }
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS
        ? '69595535813-6n7s204uk2enkavfap0kpvfpj0e4op8a.apps.googleusercontent.com'
        : null, // Android không cần clientId nếu cấu hình đúng trên Firebase Console
  );
  static Future<GoogleSignInAccount?> login() async {
    try {
      await _googleSignIn.signOut(); // Đảm bảo thoát phiên trước
      return await _googleSignIn.signIn();
    } catch (error) {
      print("Google Sign-In error: $error");
      if (error.toString().contains('PlatformException(sign_in_failed')) {
        // Log chi tiết lỗi hoặc cấu hình lại nếu cần
      }
      return null; // Trả về null nếu đăng nhập thất bại
    }
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

        // Lưu toàn bộ dữ liệu người dùng vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('userId', data['_id']);
        // await prefs.setString('tenNguoiDung', data['tenNguoiDung']);
        // await prefs.setString('gmail', data['gmail']);
        // await prefs.setString('token', data['token']);

        await prefs.setString('id', data['_id'] ?? '');
        await prefs.setString('token', data['token'] ?? '');
        await prefs.setString('anhDaiDien', data['anhDaiDien'] ?? '');
        await prefs.setString('tenNguoiDung', data['tenNguoiDung'] ?? '');
        await prefs.setString('soDienThoai', data['soDienThoai'] ?? '');
        await prefs.setString('gmail', data['gmail'] ?? '');
        await prefs.setString('GioiTinh', data['GioiTinh'] ?? '');
        await prefs.setString('ngaySinh', data['ngaySinh'] ?? '');
        await prefs.setBool('hoKinhDoanh', data['hoKinhDoanh'] ?? false);
        await prefs.setInt('tinhTrang', data['tinhTrang'] ?? 0);
        await prefs.setStringList(
            'phuongThucThanhToan', data['phuongThucThanhToan'] ?? []);
        await prefs.setString('role', data['role'] ?? 'khachhang');
        await prefs.setBool('isVerified', data['isVerified'] ?? false);
        await prefs.setString('googleId', data['googleId'] ?? '');
        await prefs.setString('facebookId', data['facebookId'] ?? '');
        await prefs.setString('userId', data['userId'] ?? '');
        await prefs.setString('IDYeuThich', data['IDYeuThich'] ?? '');
        await prefs.setStringList('follower', data['follower'] ?? []);
        await prefs.setStringList(
            'following', data['followingfollowing'] ?? []);
        await prefs.setInt('soTienHienTai', data['soTienHienTai'] ?? 0);

        // Bạn có thể thêm các dữ liệu khác nếu cần
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
