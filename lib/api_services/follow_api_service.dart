import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FollowApiService {
  Future<void> toggleFollowUser({
  required String userId,
  required String targetId,
  required String action, // 'follow' or 'unfollow'
}) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/user/toggleFollowUser');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
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
       print('Error: ${response.body}' );
    }
  } catch (error) {
    print('Error occurred while toggling follow/unfollow: $error');
  }
}
}


