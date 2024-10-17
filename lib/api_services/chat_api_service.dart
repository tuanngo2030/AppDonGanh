import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApiService{
   Future<void> createConversation(String senderId, String receiverId) async {
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
        
      } else {
        print('Failed to create conversation: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}