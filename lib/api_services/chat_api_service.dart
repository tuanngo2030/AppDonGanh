import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApiService{
   Future<bool> createConversation(String senderId, String receiverId) async {
    const String apiUrl = "https://imp-model-widely.ngrok-free.app/api/chatsocket/Createconversation";
    try {
      Map<String, String> body = {
        'sender_id': senderId,
        'receiver_id': receiverId,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Conversation created: $data');
        return true; // Indicate success
      } else {
        print('Failed to create conversation: ${response.body}');
        return false; // Indicate failure
      }
    } catch (error) {
      print('Error: $error');
      return false; // Indicate failure
    }
  }

  // Phương thức lấy danh sách cuộc trò chuyện theo ID
  Future<void> getListConversation(String conversationId) async {
    const String apiUrl = "https://imp-model-widely.ngrok-free.app/api/chatsocket/getlistconversation/";

    try {
      final response = await http.get(
        Uri.parse('$apiUrl$conversationId'), // Nối conversationId vào URL
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversations = jsonDecode(response.body);
        print('List of conversations: $conversations');
        // Xử lý danh sách cuộc trò chuyện ở đây (có thể trả về hoặc lưu trữ)
      } else {
        print('Failed to get list of conversations: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

Future<String?> uploadFile(File file, String type) async {
  try {
    String endpoint = 'https://imp-model-widely.ngrok-free.app/api/user/upload_ImageOrVideo';
    var request = http.MultipartRequest('POST', Uri.parse(endpoint));

    // Thêm file vào request
    request.files.add(
      await http.MultipartFile.fromPath(
        type == 'image' ? 'image' : 'video', // Tên field tương ứng với loại file
        file.path, // Đường dẫn tới file cần upload
      ),
    );

    request.fields['type'] = type;

    // Gửi yêu cầu và nhận phản hồi
    final response = await request.send();
    
    if (response.statusCode == 200) {
      // Xử lý phản hồi từ server
      final responseData = await http.Response.fromStream(response);
      print('Response data: ${responseData.body}');

      // Parse JSON từ phản hồi
      final jsonResponse = jsonDecode(responseData.body);
      print('JSON Response: $jsonResponse');

      // Truy xuất URL ảnh hoặc video từ phản hồi
      String? url = type == 'image' ? jsonResponse['imageUrl'] : jsonResponse['videoUrl'];

      // Kiểm tra nếu URL hợp lệ (URL phải bắt đầu bằng http hoặc https)
      if (url != null && url.startsWith('http')) {
        return url; // Trả về URL hợp lệ
      } else {
        print('Invalid URL received: $url');
        return null;
      }
    } else {
      print('Upload failed with status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}

}