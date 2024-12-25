import 'dart:convert';
import 'package:don_ganh_app/models/yeu_cau_rut_tien_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class YeuCauRutTienApi {

  // Helper function to get the token from SharedPreferences
  Future<String?> _getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Assuming token is saved as 'token'
  }

  Future<List<WithdrawalRequest>> getListYeuCauRutTienByuserId(String userId) async {
    final token = await _getTokenFromSharedPreferences();
    final url = Uri.parse('${dotenv.env['API_URL']}/user/getListYeuCauRutTienByuserId/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Add token to headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<WithdrawalRequest> withdrawalRequests = (data['data'] as List)
              .map((requestData) => WithdrawalRequest.fromJson(requestData))
              .toList();

          return withdrawalRequests;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch withdrawal requests');
      }
    } catch (error) {
      throw Exception('Failed to fetch withdrawal requests: $error');
    }
  }

  Future<Map<String, dynamic>> createYeuCauRutTien({
    required String userId,
    required String tenNganHang,
    required String soTaiKhoan,
    required double soTien,
    String? ghiChu,
  }) async {
    final token = await _getTokenFromSharedPreferences();
    final url = Uri.parse('${dotenv.env['API_URL']}/user/createYeuCauRutTien');

    try {
      final requestBody = {
        'userId': userId,
        'tenNganHang': tenNganHang,
        'soTaiKhoan': soTaiKhoan,
        'soTien': soTien,
        'ghiChu': ghiChu ?? '',
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Add token to headers
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'request': data['request'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'An error occurred',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to create withdrawal request: $error',
      };
    }
  }

  Future<Map<String, dynamic>> deleteWithdrawalRequest(String yeuCauId) async {
    final token = await _getTokenFromSharedPreferences();
    final url = Uri.parse('${dotenv.env['API_URL']}/user/deleteYeuCauRutTienCoDieuKien/$yeuCauId');

    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token to headers
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception(json.decode(response.body)['message']);
      } else if (response.statusCode == 400) {
        throw Exception(json.decode(response.body)['message']);
      } else {
        throw Exception('Đã xảy ra lỗi không xác định');
      }
    } catch (error) {
      throw Exception('Lỗi khi thực hiện yêu cầu: $error');
    }
  }

  Future<Map<String, dynamic>> resendYeuCauRutTien(String yeuCauId) async {
    final token = await _getTokenFromSharedPreferences();
    final url = Uri.parse('${dotenv.env['API_URL']}/user/resendYeuCauRutTien/$yeuCauId');

    try {
      final response = await http.post(url, headers: {
        if (token != null) 'Authorization': 'Bearer $token', // Add token to headers
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'message': 'Lỗi khi gửi lại email xác thực'};
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      return {'message': 'Đã xảy ra lỗi khi gọi API'};
    }
  }
}
