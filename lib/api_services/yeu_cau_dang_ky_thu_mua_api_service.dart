import 'dart:convert';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class YeuCauDangKyService {

  Future<Map<String, dynamic>> createYeuCauDangKy({
    required String userId,
    required String ghiChu,
    required int soluongloaisanpham,
    required int soluongsanpham,
    required diaChiList diaChiMoi,
    required String hinhthucgiaohang,
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/yeucaudangky/createYeuCauDangKy'); // Thay endpoint đúng
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "ghiChu": ghiChu,
          "soluongloaisanpham": soluongloaisanpham,
          "soluongsanpham": soluongsanpham,
          "diaChi": diaChiMoi.toJson(),
          "hinhthucgiaohang": hinhthucgiaohang,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create yêu cầu đăng ký: ${response.body}");
      }
    } catch (error) {
      print("Error in createYeuCauDangKy: $error");
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getYeuCauDangKyDiaChiByUserId(String userId) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/yeucaudangky/getYeuCauDangKyDiaChiByUserId/$userId');
  
  try {
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

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
Future<Map<String, dynamic>> updateDiaChiHoKinhDoanh({
  required String yeucaudangkyId,
  required String diaChiMoi,
}) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/yeucaudangky/updateDiaChiHoKinhDoanh/$yeucaudangkyId');
  
  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "diachimoi": diaChiMoi,
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
