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
}
