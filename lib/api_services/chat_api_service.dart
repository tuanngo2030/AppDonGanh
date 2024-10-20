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
}