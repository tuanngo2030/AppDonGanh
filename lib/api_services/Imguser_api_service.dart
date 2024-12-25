import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Import SharedPreferences

class UserImageUploadService {
  final String baseUrl = '${dotenv.env['API_URL']}/user/createAnhDaiDien';

  // Helper method to get the token from SharedPreferences
  Future<String?> _getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Assuming the token is stored under 'token'
  }

  Future<bool> uploadImage(File imageFile, String userId) async {
    try {
      final token = await _getTokenFromSharedPreferences(); // Get token from SharedPreferences
      if (token == null) {
        print('No token found in SharedPreferences');
        return false; // Return false if no token is found
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$userId'), // URL with userId
      );

      // Add token to the headers
      request.headers['Authorization'] = 'Bearer $token';

      // Determine the file MIME type based on the file extension
      var fileExtension = imageFile.path.split('.').last.toLowerCase();
      var mimeType = 'image/jpeg'; // Default MIME type

      if (fileExtension == 'png') {
        mimeType = 'image/png';
      } else if (fileExtension == 'gif') {
        mimeType = 'image/gif';
      }

      // Add the image file to the request with the correct MIME type
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Image uploaded successfully');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to upload image: ${response.statusCode}');
        print('Response body: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }
}
