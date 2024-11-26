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

 void _onChat(String targetId) async {
  setState(() {
    _isLoading = true; // Bắt đầu trạng thái tải
  });

  final ChatApiService apiService = ChatApiService();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userId = prefs.getString('userId');
  token = prefs.getString('token');

  if (userId != null && token != null) {
    try {
      print('User ID: $userId');
      print('Token: $token');

      // Gửi API để tạo cuộc trò chuyện
      final response = await apiService.createConversation(userId!, targetId);

      if (response != null && response['_id'] != null) {
        String conversationId = response['_id'];

        print('conversationId: $conversationId');

        bool isCurrentUserSender = (userId == response['sender_id']['_id']);

        // Điều hướng sang màn hình ChatScreenThumua
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreenThumua(
              token: token!,
              title: conversationId,
              userId: userId!,
              conversationId: conversationId,
              receiverData: isCurrentUserSender
                  ? response['receiver_id'] ?? {} // Nếu là sender, hiển thị receiver
                  : response['sender_id'] ?? {}, // Nếu không, hiển thị sender
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
    _isLoading = false; // Kết thúc trạng thái tải
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
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(),
      ),
      title: const Text(
        'Danh sách cuộc trò chuyện',
        style: TextStyle(
            color: Color.fromRGBO(41, 87, 35, 1), fontWeight: FontWeight.bold),
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
              var sender = conversation.senderId;
              var receiver = conversation.receiverId;

              // Kiểm tra userId lấy từ SharedPreferences có trùng với senderId
              var isCurrentUserSender = sender?.id == userId;

              // Nếu là sender thì hiển thị thông tin sender, nếu không thì hiển thị thông tin receiver
              var displayUser = isCurrentUserSender ? receiver : sender;

              // Bỏ qua nếu không có tin nhắn
              if (conversation.messageIds.isEmpty) {
                return const SizedBox.shrink(); // Không hiển thị gì
              }

              return ListTile(
                leading: CircleAvatar(
                  child: displayUser?.anhDaiDien != null
                      ? Image.network(
                          displayUser!.anhDaiDien!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                color: Colors.grey); // Fallback icon
                          },
                        )
                      : const Icon(Icons.person,
                          color: Colors.grey), // Default icon if no image
                ),
                title: Text(
                  displayUser?.tenNguoiDung ?? 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Nhấn để bắt đầu trò chuyện'),
                onTap: () {
                  // Nếu là sender thì gửi receiverId, nếu không thì gửi senderId
                  _onChat(isCurrentUserSender
                      ? receiver?.id ?? 'Unknown'
                      : sender?.id ?? 'Unknown');
                },
              );
            },
          ),
  );
}
}