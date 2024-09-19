import 'package:don_ganh_app/models/chat_model.dart';
import 'package:don_ganh_app/widget/custom_card_chat.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class NotifitionScreen extends StatefulWidget {
  const NotifitionScreen({super.key});

  @override
  State<NotifitionScreen> createState() => _NotifitionScreenState();
}

class _NotifitionScreenState extends State<NotifitionScreen> {
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
    ChatModel(
      name: 'Vợ 3',
      isGroup: false,
      icon: 'lib/assets/avt1.jpg',
      currentMessage: 'Tin nhắn mới',
      time: '15:00',
    ),
    ChatModel(
      name: 'Vợ 10',
      isGroup: false,
      icon: 'lib/assets/avt1.jpg',
      currentMessage: 'Tin nhắn mới',
      time: '15:00',
    )
  ];

  // List<Map<String, String>> todayNotifications = [
  //   {
  //     'title': 'Tin từ vợ 1',
  //     'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
  //     'time': '1h',
  //     'imageUrl': 'lib/assets/avt1.jpg',
  //   },
  //   {
  //     'title': 'Tin từ vợ 2',
  //     'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
  //     'time': '1h',
  //     'imageUrl': 'lib/assets/avt2.jpg',
  //   },
  //   {
  //     'title': 'Tin từ vợ 3',
  //     'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
  //     'time': '1h',
  //     'imageUrl': 'lib/assets/avt3.jpg',
  //   },
  // ];

  // List<Map<String, String>> yesterdayNotifications = [
  //   {
  //     'title': 'Tin từ vợ 4',
  //     'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
  //     'time': '1d',
  //     'imageUrl': 'lib/assets/avt4.jpg',
  //   },
  //   {
  //     'title': 'Tin từ vợ 5',
  //     'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
  //     'time': '1d',
  //     'imageUrl': 'lib/assets/avt5.jpg',
  //   },
  // ];

  // // Example function to mark notifications as read
  // void markAllAsRead() {
  //   setState(() {
  //     todayNotifications = todayNotifications
  //         .map((notification) => {
  //               ...notification,
  //               'description': 'Đã đọc - ' + notification['description']!
  //             })
  //         .toList();
  //     yesterdayNotifications = yesterdayNotifications
  //         .map((notification) => {
  //               ...notification,
  //               'description': 'Đã đọc - ' + notification['description']!
  //             })
  //         .toList();
  //   });
  // }

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
          itemBuilder: (context, index) => CustomCardChat(chatModel:  chats[index])
          // padding: const EdgeInsets.all(8.0),
          // children: [
          //   // "Hôm nay" section
          //   const Text(
          //     'Hôm nay',
          //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          //   ),
          //   ListTile(
          //     title: Align(
          //       alignment: Alignment.topRight,
          //       child: GestureDetector(
          //         onTap: markAllAsRead,
          //         child: const Text(
          //           'Đánh dấu tin đã đọc',
          //           style: TextStyle(color: Colors.green),
          //         ),
          //       ),
          //     ),
          //   ),
          //   ...todayNotifications.map((notification) =>
          //       buildNotificationItem(notification)),

          //   // "Hôm qua" section
          //   const SizedBox(height: 20),
          //   const Text(
          //     'Hôm qua',
          //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          //   ),
          //   ListTile(
          //     title: Align(
          //       alignment: Alignment.topRight,
          //       child: GestureDetector(
          //         onTap: markAllAsRead,
          //         child: const Text(
          //           'Đánh dấu tin đã đọc',
          //           style: TextStyle(color: Colors.green),
          //         ),
          //       ),
          //     ),
          //   ),
          //   ...yesterdayNotifications.map((notification) =>
          //       buildNotificationItem(notification)),

          // ],
          ),
    );
  }

  Widget buildNotificationItem(ChatModel) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage:
            AssetImage(ChatModel['icon']!), // Sử dụng đường dẫn từ thông báo
      ),
      title: Text(
        ChatModel['name']!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(ChatModel['currentMessage']!),
      trailing: Text(ChatModel['time']!),
      onTap: () {
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              title: ChatModel['name']!, // Pass the title to the chat screen
            ),
          ),
        );
      },
    );
  }
}
