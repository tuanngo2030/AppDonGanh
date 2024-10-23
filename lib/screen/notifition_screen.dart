import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/models/converstation_model.dart';
import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotifitionScreen extends StatefulWidget {
  const NotifitionScreen({super.key});

  @override
  State<NotifitionScreen> createState() => _NotifitionScreenState();
}

class _NotifitionScreenState extends State<NotifitionScreen> {
  String? userId;
  final ChatApiService apiService = ChatApiService();
  List<Conversation> conversations = []; // Store conversations

  @override
  void initState() {
    super.initState();
    _loadUserId();
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
    const String apiUrl =
        "https://peacock-wealthy-vaguely.ngrok-free.app/api/chatsocket/getlistconversation/";

    try {
      final response = await http.get(
        Uri.parse('$apiUrl$userId'), // Assume this fetches all conversations
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('error ${response.body}');
        List<dynamic> data = jsonDecode(response.body);

        // Parse and filter conversations by senderId or receiverId matching userId
        List<Conversation> allConversations =
            data.map((json) => Conversation.fromJson(json)).toList();

        setState(() {
         conversations = allConversations;
        });
      } else {
        print('Failed to get list of conversations: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
          ),
        ),
        title: Text(
          'Thông báo',
         style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1),fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              radius: 30,
              child: Icon(Icons.message), // Placeholder for icon
            ),
            title: Text(
              conversations[index]
                  .id, // Display conversation ID (or other info)
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                'Messages: ${conversations[index].messageIds.length}'), // Show number of messages
            trailing: Text(conversations[index]
                .updatedAt
                .toIso8601String()), // Show last updated time
            onTap: () async {
              if (userId != null) {
                try {
                  // In ra userId
                  print('User ID: $userId'); // Thêm dòng này để in ra userId

                  final conversationId = conversations[index].id;
                  String receiverId = '671326ec38c65820c766c473';
                  final success =
                      await apiService.createConversation(userId!, receiverId);
                  print('conversationId: $conversationId');
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          title: conversations[index].receiverId,
                          userId: userId!, // Gửi userId tới ChatScreen
                          conversationId:
                              conversationId, // Gửi conversationId tới ChatScreen // Set chat screen title as conversation ID
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
                _showSnackBar('Không tìm thấy người dùng.');
              }
            },
          );
        },
      ),
    );
  }

  // Method to show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
