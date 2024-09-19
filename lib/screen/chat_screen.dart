import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String title; // Accept the title as a parameter

  const ChatScreen({Key? key, required this.title}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Customer Support',
      'message': 'Đơn hàng của quý khách "SẦU RIÊNG" đang bắt đầu giao, dự kiến giao tới quý khách trong vòng 1 giờ.',
      'time': '14:26',
      'isUserMessage': false,
    },
    {
      'sender': 'User',
      'message': 'Khi nào tới nhớ nhấn chuông. Người nhà ra lấy, mình đang họp không tiện về lấy.',
      'time': '14:50',
      'isUserMessage': true,
    },
    {
      'sender': 'Customer Support',
      'message': 'Vâng thưa chị',
      'time': '14:51',
      'isUserMessage': false,
    },
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'User',
          'message': _controller.text,
          'time': TimeOfDay.now().format(context), // Current time
          'isUserMessage': true,
        });
        _controller.clear(); // Clear the input field after sending the message
      });

      // Scroll to the last message
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Use the title passed to the ChatScreen
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: <Widget>[
          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Add scroll controller
              reverse: true, // Show the latest messages at the bottom
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
          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                // Text field
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    controller: _controller, // Link the controller
                    decoration: InputDecoration(
                      hintText: 'Nhắn tin...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.attach_file),
                          ),

                          IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.camera_alt_outlined),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
                // Send button
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Call send message function
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

  const ChatBubble({
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
          crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isUserMessage ? Colors.green[200] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(message, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 2),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
