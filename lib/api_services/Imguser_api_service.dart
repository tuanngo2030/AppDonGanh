import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserImageUploadService {
  final String baseUrl = '${dotenv.env['API_URL']}/user/createAnhDaiDien';

  Future<bool> uploadImage(File imageFile, String userId) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$userId'), // URL kèm userId
      );

      // Thêm tệp ảnh vào yêu cầu
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
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
