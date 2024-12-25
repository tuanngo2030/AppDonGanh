import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowApiService {
  // Helper method to get the token from SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Toggle follow/unfollow user
  Future<void> toggleFollowUser({
    required String userId,
    required String targetId,
    required String action, // 'follow' or 'unfollow'
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/user/toggleFollowUser');
    final token = await _getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token here
        },
        body: jsonEncode({
          'userId': userId,
          'targetId': targetId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print('Error: ${response.body}');
      }
    } catch (error) {
      print('Error occurred while toggling follow/unfollow: $error');
    }
  }
}
