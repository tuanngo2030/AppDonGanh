import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String title; // Tiêu đề nhận từ tham số

  const ChatScreen({super.key, required this.title});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late IO.Socket socket;

  String? storedUserId;
  String? token;
  String? receiverId;

  @override
  void initState() {
    super.initState();
    connect();
    // _initializeChat();
  }

   void connect(){
      socket = IO.io(
        "https://upward-urchin-pleasant.ngrok-free.app",
        <String, dynamic>{
          "transports" : ["websocket"],
          "autoConnect" : false,
        }
      );
      socket.connect();
      socket.emit("/test", "hello world");

      socket.onConnect((data) => print("CONNECT"));
      print("Socket connected: ${socket.connected}");

      
    }


     void sendMessage(String text) {
    if (text.isEmpty) return;

    final message = {
      'message': text,
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'isUserMessage': true,
    };
    // addMessage(message, isUserMessage: true);

    socket.emit('sendMessage', {
      // 'conversationId': widget.conversationId,
      'message': text,
    });

    _controller.clear();
    _scrollToBottom();
  }

  void addMessage(String text, {required bool isUserMessage}) {
    final message = {
      'message': text,
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'isUserMessage': isUserMessage,
    };

    setState(() {
      messages.insert(0, message);
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Sử dụng tiêu đề truyền vào
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: <Widget>[
          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Thêm scroll controller
              reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return ChatBubble(
                  sender: message['sender'],
                  message: message['message'],
                  time: message['time'],
                  isUserMessage: message['isUserMessage'],
                );
              },
            ),
          ),
          // Trường nhập liệu và nút gửi
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                // Trường nhập liệu
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    controller: _controller, // Liên kết controller
                    decoration: InputDecoration(
                      hintText: 'Nhắn tin...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.attach_file),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.camera_alt_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Nút gửi
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (){}
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String time;
  final bool isUserMessage;

  const ChatBubble({super.key, 
    required this.sender,
    required this.message,
    required this.time,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment:
              isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isUserMessage ? Colors.green[200] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 2),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
