import 'dart:convert';

import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/models/converstation_model.dart';
import 'package:don_ganh_app/thu_mua_screen/chat_screen_thuMua.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ListConversation extends StatefulWidget {
  const ListConversation({super.key});

  @override
  State<ListConversation> createState() => _ListConversationState();
}

class _ListConversationState extends State<ListConversation> {
  String? userId;
  final ChatApiService apiService = ChatApiService();
  List<Conversation> conversations = []; // Store conversations
  bool _isLoading = false; // Biến để theo dõi trạng thái tải
  final double _uploadProgress = 0.0;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _onChat(String receiverId) async {
    setState(() {
      _isLoading = true; // Start loading state
    });

    final ChatApiService apiService = ChatApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('token');

    if (userId != null && token != null) {
      // Ensure userId and token are not null
      try {
        print('User ID: $userId');
        print('Token: $token');

        final response =
            await apiService.createConversation(userId!, receiverId);

        if (response != null && response['_id'] != null) {
          String conversationId = response['_id'];

          print('conversationId: $conversationId');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenThumua(
                token: token!,
                title: conversationId,
                userId: userId!,
                conversationId: conversationId,
                receiverData: response['receiver_id'] ?? {},
              ),
            ),
          );
        } else {
          _showSnackBar('Không thể tạo cuộc trò chuyện.');
        }
      } catch (e) {
        _showSnackBar('Đã xảy ra lỗi: $e');
      }
    } else {
      _showSnackBar('User ID hoặc token không có sẵn.');
    }

    setState(() {
      _isLoading = false; // End loading state
    });
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    setState(() {}); // Update UI after userId is loaded

    if (userId != null) {
      await getListConversationsByUserId(userId!);
    }
  }

  // Fetch conversations and filter by userId
  Future<void> getListConversationsByUserId(String userId) async {
    String apiUrl = "${dotenv.env['API_URL']}/chatsocket/getlistconversation/";

    try {
      final response = await http.get(
        Uri.parse('$apiUrl$userId'), // API URL
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          // Convert List<dynamic> to List<Conversation> using the fromJson method
          conversations = data
              .map(
                  (conversationJson) => Conversation.fromJson(conversationJson))
              .toList();
        });
      } else {
        print('Failed to get list of conversations: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Method to show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách cuộc trò chuyện',
          style: TextStyle(
            color: Color.fromRGBO(41, 87, 35, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Text('Chưa có đoạn hội thoại'),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                var conversation = conversations[index];
                var receiver = conversation.receiverId;

                // Bỏ qua nếu không có tin nhắn
                if (conversation.messageIds.isEmpty) {
                  return const SizedBox.shrink(); // Không hiển thị gì
                }

                return ListTile(
                  leading: CircleAvatar(
                    // Use null-aware operator to safely access properties
                    backgroundImage: receiver?.anhDaiDien != null
                        ? NetworkImage(receiver!
                            .anhDaiDien!) // null check for non-null receiver
                        : null,
                    child: receiver?.anhDaiDien == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  title: Text(
                    receiver?.tenNguoiDung ??
                        'Unknown User', // Fallback to 'Unknown User' if null
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Nhấn để bắt đầu trò chuyện'),
                  onTap: () {
                    // If receiver?.id is null, pass a default string like "Unknown" or empty string
                    _onChat(receiver?.id ?? 'Unknown');
                  },
                );
              },
            ),
    );
  }
}
