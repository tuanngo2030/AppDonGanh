import 'dart:convert';
import 'package:don_ganh_app/models/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationApi {
  static const String baseUrl =
      "https://chipmunk-pro-phoenix.ngrok-free.app/api/user";

  // Lấy danh sách thông báo
  static Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final url = Uri.parse("$baseUrl/getListThongBao/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception("Invalid response format: Expected a List of notifications.");
      }
    } else {
      throw Exception("Lỗi khi lấy thông báo: ${response.statusCode}");
    }
  }

  // Cập nhật trạng thái đã đọc của một thông báo
  static Future<void> updateNotificationRead(String thongBaoId) async {
    final url = Uri.parse("$baseUrl/updateDaDoc/$thongBaoId");
    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi cập nhật thông báo: ${response.statusCode}");
    }
  }

  // Cập nhật tất cả thông báo thành đã đọc
  static Future<void> updateAllNotificationsRead(String userId) async {
    final url = Uri.parse("$baseUrl/updateDaDocAll/$userId");
    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi cập nhật tất cả thông báo: ${response.statusCode}");
    }
  }
  // Xóa một thông báo
  static Future<void> deleteThongBao(String thongBaoId) async {
    final url = Uri.parse("$baseUrl/deleteThongBao/$thongBaoId");
    final response = await http.delete(url);

 if (response.statusCode != 200) {
  print("Response body: ${response.body}");
  throw Exception("Lỗi khi xóa thông báo: ${response.statusCode}");
}

  }

  // Xóa tất cả thông báo của người dùng
  static Future<void> deleteAllThongBao(String userId) async {
    final url = Uri.parse("$baseUrl/deleteAllThongBao/$userId");
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi xóa tất cả thông báo: ${response.statusCode}");
    }
  }
  
}
