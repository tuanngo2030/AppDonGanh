import 'dart:convert';
import 'package:don_ganh_app/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationApi {
  static String baseUrl = "${dotenv.env['API_URL']}/user";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  static Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final token = await getToken(); 
    final url = Uri.parse("$baseUrl/getListThongBao/$userId");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

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

  static Future<void> updateNotificationRead(String thongBaoId) async {
    final token = await getToken(); 
    final url = Uri.parse("$baseUrl/updateDaDoc/$thongBaoId");

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add token in the header
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi cập nhật thông báo: ${response.statusCode}");
    }
  }

  // Update all notifications read with token included in the header
  static Future<void> updateAllNotificationsRead(String userId) async {
    final token = await getToken(); // Retrieve the token
    final url = Uri.parse("$baseUrl/updateDaDocAll/$userId");

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add token in the header
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi cập nhật tất cả thông báo: ${response.statusCode}");
    }
  }

  // Delete a notification with token included in the header
  static Future<void> deleteThongBao(String thongBaoId) async {
    final token = await getToken(); // Retrieve the token
    final url = Uri.parse("$baseUrl/deleteThongBao/$thongBaoId");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add token in the header
      },
    );

    if (response.statusCode != 200) {
      print("Response body: ${response.body}");
      throw Exception("Lỗi khi xóa thông báo: ${response.statusCode}");
    }
  }

  // Delete all notifications with token included in the header
  static Future<void> deleteAllThongBao(String userId) async {
    final token = await getToken(); // Retrieve the token
    final url = Uri.parse("$baseUrl/deleteAllThongBao/$userId");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add token in the header
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Lỗi khi xóa tất cả thông báo: ${response.statusCode}");
    }
  }

  // Save FCM token with token included in the header
  Future<Map<String, dynamic>> saveFcmTokenFirebase({
    required String userId,
    required String fcmToken,
  }) async {
    final token = await getToken(); // Retrieve the token
    final url = Uri.parse('$baseUrl/saveFcmTokenFireBase');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token in the header
        },
        body: jsonEncode({
          'userId': userId,
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Something went wrong',
        };
      }
    } catch (error) {
      print('Error while saving FCM token: $error');
      return {
        'success': false,
        'message': 'An error occurred while saving the FCM token',
      };
    }
  }
}
