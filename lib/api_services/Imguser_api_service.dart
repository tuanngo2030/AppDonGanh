// lib/api_services/user_image_upload_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;

class UserImageUploadService {
 final String _baseUrl = 'https://imp-model-widely.ngrok-free.app/api/user/createAnhDaiDien';// Thay đổi URL cơ sở của bạn

  Future<bool> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload_image'), // Thay đổi đường dẫn API cho việc tải ảnh lên
      );

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final response = await request.send();

      if (response.statusCode == 200) {
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

