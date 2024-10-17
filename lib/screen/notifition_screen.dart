import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifitionScreen extends StatefulWidget {
  const NotifitionScreen({super.key});

  @override
  State<NotifitionScreen> createState() => _NotifitionScreenState();
}

class _NotifitionScreenState extends State<NotifitionScreen> {
  String? userId;
  List<ChatModel> chats = [
    ChatModel(
      name: 'Vợ 1',
      isGroup: false,
      icon: 'lib/assets/avt1.jpg',
      currentMessage: 'Tin nhắn mới',
      time: '15:00',
    ),
    ChatModel(
      name: 'Vợ 2',
      isGroup: false,
      icon: 'lib/assets/avt1.jpg',
      currentMessage: 'Tin nhắn mới',
      time: '15:00',
    ),
  ];

  final ChatApiService apiService = ChatApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(chats[index].icon),
            ),
            title: Text(
              chats[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(chats[index].currentMessage),
            trailing: Text(chats[index].time),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              userId = prefs.getString('userId');
              await apiService.createConversation('$userId', '670532d8d679dbe8766bcbf0');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    title: chats[index].name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
