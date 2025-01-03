import 'dart:convert';
import 'dart:io';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper function to get the token from SharedPreferences
Future<String?> _getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // Assuming the token is stored under the key 'token'
}

class YeuCauDangKyService {

  // Create YeuCauDangKy
  Future<Map<String, dynamic>> createYeuCauDangKy({
    required String userId,
    required String ghiChu,
    required int soluongloaisanpham,
    required int soluongsanpham,
    required diaChiList diaChiMoi,
    required String hinhthucgiaohang,
    required String maSoThue,
    required String gmail,
    required File? file, // Make file nullable
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/yeucaudangky/createYeuCauDangKy');
    
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['userId'] = userId;
      request.fields['gmail'] = gmail;
      request.fields['ghiChu'] = ghiChu;
      request.fields['soluongloaisanpham'] = soluongloaisanpham.toString();
      request.fields['soluongsanpham'] = soluongsanpham.toString();
      request.fields['diaChi'] = jsonEncode(diaChiMoi.toJson());
      request.fields['hinhthucgiaohang'] = hinhthucgiaohang;
      request.fields['maSoThue'] = maSoThue;
      
      // Get token from SharedPreferences and add it to headers
      final token = await _getTokenFromSharedPreferences();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Check if file is provided
      if (file != null) {
        // Read the file as bytes
        var fileBytes = await file.readAsBytes();
        
        // Determine MIME type based on file extension
        String mimeType = 'application/octet-stream'; // Default MIME type
        if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else if (file.path.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (file.path.endsWith('.pdf')) {
          mimeType = 'application/pdf';
        }
        
        // Create MultipartFile with MIME type
        var multipartFile = http.MultipartFile.fromBytes(
          'file', fileBytes, 
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
        
        // Add file to the request
        request.files.add(multipartFile);
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await http.Response.fromStream(response);
        return jsonDecode(responseBody.body);
      } else {
        throw Exception("Failed to create yêu cầu đăng ký: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Error in createYeuCauDangKy: $error");
      rethrow;
    }
  }

  // Get YeuCauDangKy DiaChi By UserId
  Future<Map<String, dynamic>> getYeuCauDangKyDiaChiByUserId(String userId) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/yeucaudangky/getYeuCauDangKyDiaChiByUserId/$userId');
    
    try {
      // Get token from SharedPreferences and add it to headers
      final token = await _getTokenFromSharedPreferences();
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("Không tìm thấy yêu cầu đăng ký");
      } else {
        throw Exception("Lỗi khi lấy yêu cầu đăng ký: ${response.body}");
      }
    } catch (error) {
      print("Error in getYeuCauDangKyDiaChiByUserId: $error");
      rethrow;
    }
  }

  // Update DiaChi Ho Kinh Doanh
  Future<Map<String, dynamic>> updateDiaChiHoKinhDoanh({
    required String yeucaudangkyId,
    required diaChiList diaChiMoi,
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/yeucaudangky/updateDiaChiHoKinhDoanh/$yeucaudangkyId');
    
    try {
      // Get token from SharedPreferences and add it to headers
      final token = await _getTokenFromSharedPreferences();
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "diachimoi": diaChiMoi.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("Không tìm thấy yêu cầu đăng ký");
      } else if (response.statusCode == 400) {
        throw Exception("Địa chỉ mới không hợp lệ");
      } else {
        throw Exception("Lỗi khi cập nhật địa chỉ: ${response.body}");
      }
    } catch (error) {
      print("Error in updateDiaChiHoKinhDoanh: $error");
      rethrow;
    }
  }
}
