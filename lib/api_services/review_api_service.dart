import 'dart:io';
import 'package:don_ganh_app/models/review_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewApiService {
  final String baseUrl = '${dotenv.env['API_URL']}';
  String? userId;

  // Phương thức lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Giả sử bạn lưu token với khóa 'token'
  }

  // Phương thức lấy danh sách đánh giá sản phẩm
  Future<List<DanhGia>> getReviewsByProductId(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    final url = Uri.parse('$baseUrl/danhgia/getListDanhGiaInSanPhamById/$productId/$userId');

    // Lấy token từ SharedPreferences và thêm vào header
    String? token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((json) => DanhGia.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Phương thức tạo đánh giá
  Future<String> createReview({
    required String userId,
    required String sanphamId,
    required int xepHang,
    required String binhLuan,
    List<File>? imageFiles,
  }) async {
    final url = Uri.parse('$baseUrl/danhgia/createDanhGia');

    var request = http.MultipartRequest('POST', url);

    request.fields['userId'] = userId;
    request.fields['sanphamId'] = sanphamId;
    request.fields['XepHang'] = xepHang.toString();
    request.fields['BinhLuan'] = binhLuan;

    if (imageFiles != null) {
      for (var imageFile in imageFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          'files',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }
    }

    // Lấy token từ SharedPreferences và thêm vào header
    String? token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    request.headers['Authorization'] = 'Bearer $token'; // Thêm token vào header

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['message'] ?? 'Đánh giá thành công';
      } else {
        return jsonResponse['message'] ?? 'Đánh giá thất bại';
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo đánh giá: $e');
    }
  }

  // Phương thức xóa đánh giá
  Future<void> deleteReview(String spId, String reviewId) async {
    final url = Uri.parse('$baseUrl/danhgia/deleteDanhGia/$spId/$reviewId');

    // Lấy token từ SharedPreferences và thêm vào header
    String? token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
      );
      if (response.statusCode == 200) {
        print('Review deleted successfully');
      } else {
        print('Failed to delete review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  // Phương thức cập nhật đánh giá
  Future<void> updateReview({
    required String danhGiaId,
    required int xepHang,
    required String binhLuan,
  }) async {
    final url = Uri.parse('$baseUrl/danhgia/updateDanhGia/$danhGiaId');

    // Lấy token từ SharedPreferences và thêm vào header
    String? token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
        body: json.encode({
          'XepHang': xepHang,
          'BinhLuan': binhLuan,
        }),
      );

      if (response.statusCode == 200) {
        print('Review updated successfully');
      } else {
        print('Failed to update review: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating review: $e');
    }
  }

  // Phương thức cập nhật like
  Future<void> updateLike(String phanHoiId, String userId) async {
    final url = Uri.parse('$baseUrl/danhgia/updateLike/$phanHoiId/$userId');

    // Lấy token từ SharedPreferences và thêm vào header
    String? token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
      );

      if (response.statusCode == 200) {
        print('Like updated successfully');
      } else if (response.statusCode == 404) {
        print('Review not found');
      } else {
        print('Failed to update like: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating like: $e');
    }
  }
}
