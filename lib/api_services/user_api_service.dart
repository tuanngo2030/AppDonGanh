import 'dart:convert';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart'; 

class UserApiService {
  final String baseUrl =
      '${dotenv.env['API_URL']}/user/login';
  final String baseUrlid =
      '${dotenv.env['API_URL']}/user/showUserID';

  final String updateUserUrl =
      '${dotenv.env['API_URL']}/user/updateUser';

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
                await prefs.setString('token', token ?? '');
              await prefs.setString('anhDaiDien', user.anhDaiDien ?? '');
              await prefs.setString('tenNguoiDung', user.tenNguoiDung ?? '');
              await prefs.setString('soDienThoai', user.soDienThoai ?? '');
              await prefs.setString('gmail', user.gmail ?? '');
              await prefs.setString('GioiTinh', user.GioiTinh ?? '');
              await prefs.setString('ngaySinh', user.ngaySinh ?? '');
              await prefs.setBool('hoKinhDoanh', user.hoKinhDoanh ?? false);
              await prefs.setInt('tinhTrang', user.tinhTrang ?? 0);
              await prefs.setStringList(
                  'phuongThucThanhToan', user.phuongThucThanhToan ?? []);
              await prefs.setString('role', user.role ?? 'khachhang');
              await prefs.setBool('isVerified', user.isVerified ?? false);
              await prefs.setString('googleId', user.googleId ?? '');
              await prefs.setString('facebookId', user.facebookId ?? '');
              await prefs.setString('userId', user.id ?? '');
              await prefs.setString('IDYeuThich', user.IDYeuThich ?? '');
              await prefs.setStringList('follower', user.follower ?? []);
              await prefs.setStringList('following', user.following ?? []);
              await prefs.setInt('soTienHienTai', user.soTienHienTai ?? 0);
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

  Future<bool> updateUserInformation(String userId, String loaiThongTin, dynamic value) async {
    final url = Uri.parse(updateUserUrl);

    // Tạo body request dựa trên loại thông tin cần cập nhật
    Map<String, dynamic> requestBody = {
      'UserID': userId,
      'LoaiThongTinUpdate': loaiThongTin,
    };

    switch (loaiThongTin) {
      case 'tenNguoiDung':
        requestBody['tenNguoiDung'] = value;
        break;
      case 'soDienThoai':
        requestBody['soDienThoai'] = value;
        break;
      case 'gmail':
        requestBody['gmail'] = value;
        break;
      case 'GioiTinh':
        requestBody['GioiTinh'] = value;
        break;
      case 'matKhau':
        requestBody['matKhau'] = value;
        break;
      case 'ngaySinh':
        requestBody['ngaySinh'] = value;
        break;
      default:
        print('Invalid update type');
        return false;
    }

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Response from API: $data');
        if (data.containsKey('_id')) {
          print('Update successful');
          return true;
        } else {
          print('Update failed. Reason: ${data['message'] ?? 'Unknown error'}');
          return false;
        }
      } else {
        print('Failed to update information. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating information: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String userId, String me) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/user/findUserById/$userId/$me');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Parse the JSON response directly without using a model
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user data');
  }
}

  Future<Map<String, dynamic>> getUserFollowers(String userId) async {
    final url = Uri.parse("${dotenv.env['API_URL']}/user/getUserFollowers/$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load followers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
