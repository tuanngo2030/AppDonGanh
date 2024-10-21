import 'dart:convert';
import 'dart:io';

import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final String userId; // ID của người dùng hiện tại
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.title,
    required this.userId,
    required this.conversationId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  IO.Socket? socket;
  String? token;
  List<Message> messages = [];
  File? _image;
  File? _video;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadTokenAndConnect();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    socket?.disconnect();
    socket?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: SizedBox(
            width: MediaQuery.of(context).size.width *
                0.9, // Chiều rộng 90% màn hình
            height: MediaQuery.of(context).size.height *
                0.5, // Chiều cao 50% màn hình
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(10),
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.memory(
                base64Decode(imageUrl),
                fit: BoxFit
                    .cover, // Đặt BoxFit.cover để hình ảnh chiếm toàn bộ dialog
              ),
            ),
          ),
        );
      },
    );
  }

  // Play the received video
  void _playReceivedVideo(String base64Video) {
    final videoBytes = base64Decode(base64Video);
    final tempVideoFile = File.fromRawPath(videoBytes);
    _videoController = VideoPlayerController.file(tempVideoFile)
      ..initialize().then((_) {
        setState(() {
          _videoController!.play();
        });
      });
  }

// Hàm để chọn hình ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Lưu đường dẫn hình ảnh
      });
    }
  }

// Hàm để chọn video từ thư viện
  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(
                () {}); // Rebuild the widget when the video is ready to play
            _videoController!.play(); // Auto-play the video
          });
      });
    }
  }

  Future<void> _loadTokenAndConnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {
      connect();
    } else {
      print("Token not found");
    }
  }

  void connect() {
    // Hủy bỏ các sự kiện nếu socket đã tồn tại
    socket?.off('Joined');
    socket?.off('message');
    socket?.off('error');
    socket?.off('disconnect');
    socket?.off('reconnect');

    // Tạo socket mới
    socket = IO.io(
      "https://imp-model-widely.ngrok-free.app",
      <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": true,
        "reconnection": true,
        'auth': {
          'token': token,
        }
      },
    );

    socket!.connect();

    // Thêm các sự kiện sau khi socket được kết nối
    socket!.onConnect((_) {
      print("Connected to the server");
      socket!.emit("join", {
        'token': token,
        'conversationId': widget.conversationId,
      });
    });

    socket!.on('Joined', (data) {
      List<dynamic> previousMessages = data['messages'];
      for (var msg in previousMessages) {
        addMessage(Message.fromJson(msg));
      }

      print("Joined conversation with messages: $data");
    });

    socket!.on('message', (data) {
      if (data != null && data['message'] != null) {
        final message = Message(
          id: data['message']['_id'] ??
              '', // Sử dụng giá trị mặc định nếu không có
          text: data['message']['text'] ?? '',
          seen: false,
          msgByUserId: data['message']['msgByUserId'] ?? '', // Kiểm tra giá trị
          createdAt:
              DateTime.now(), // Sử dụng thời gian hiện tại hoặc lấy từ server
          updatedAt: DateTime.now(), // Tương tự
          imageUrl: data['message']['imageUrl'], // Thêm imageUrl nếu có
          videoUrl: data['message']['videoUrl'], // Thêm videoUrl nếu có
        );

        // Thêm tin nhắn vào danh sách
        addMessage(message);
      } else {
        print('Received null data: $data');
      }
    });

    socket!.on('error', (data) {
      print('Error: ${data['message']}');
    });

    socket!.onDisconnect((_) {
      print("Disconnected from the server");
    });

    socket!.onReconnect((_) {
      print("Reconnected to the server");
      socket!.emit("join", {
        'token': token,
        'conversationId': widget.conversationId,
      });
    });
  }

  // Hàm để chuyển đổi tệp thành base64
  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  void sendMessage(String text) async {
    if (text.isEmpty && _image == null && _video == null) return;

    if (socket != null && socket!.connected) {
      String? imageUrl;
      String? videoUrl;

      // Nếu có hình ảnh, chuyển đổi thành base64
      if (_image != null) {
        imageUrl = await _fileToBase64(_image!);
          // imageUrl = await ChatApiService().uploadFile(_image!, 'image');
      }

      // Nếu có video, chuyển đổi thành base64
      if (_video != null) {
        videoUrl = await _fileToBase64(_video!);
        // videoUrl = await ChatApiService().uploadFile(_video!, 'video');
        print('videoUrl: $videoUrl');
      }

      // Tạo một message mới
      final message = Message(
        id: '', // ID sẽ được tạo bởi server
        text: text,
        seen: false,
        msgByUserId: widget.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: imageUrl,
        videoUrl: videoUrl,
      );

      // Thêm tin nhắn vào danh sách ngay lập tức
      // addMessage(message);

      // Gửi tin nhắn
      socket!.emit('sendMessage', {
        'conversationId': widget.conversationId,
        'text': text,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
      });

      // Xóa trường nhập và các biến sau khi gửi
      _controller.clear();
      setState(() {
        _image = null; // Reset image after sending
        _video = null; // Reset video after sending
        _videoController?.dispose(); // Dispose video controller after sending
        _videoController = null;
      });
    } else {
      print("Socket is not connected.");
    }
  }

  void addMessage(Message message) {
    if (mounted) {
      setState(() {
        messages.add(message);
      });
      // Gọi _scrollToBottom() sau khi cập nhật danh sách tin nhắn
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessage(message);
                },
              ),
            ),
            if (_image != null) // Hiển thị hình ảnh nếu có
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                        width: 100, height: 100, child: Image.file(_image!))),
              ),
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 150,
                  width: 200,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!), // Display video player
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.video_library),
                    onPressed: _pickVideo,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Message message) {
    String formattedTime = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      // Sử dụng Padding để tạo khoảng cách
      padding:
          const EdgeInsets.symmetric(vertical: 8.0), // Khoảng cách trên và dưới
      child: Column(
        crossAxisAlignment: message.msgByUserId == widget.userId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.msgByUserId == widget.userId
                    ? Colors.green[200]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: message.msgByUserId == widget.userId
                    ? CrossAxisAlignment.end // Căn phải cho người gửi
                    : CrossAxisAlignment.start, // Căn trái cho người nhận
                children: [
                  Text(message.text, style: const TextStyle(fontSize: 16)),
                  const SizedBox(
                      height: 4), // Khoảng cách giữa tin nhắn và thời gian
                  Text(
                    formattedTime, // Hiển thị thời gian
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          if (message.imageUrl != null)
            GestureDetector(
              onTap: () {
                _showFullImage(message.imageUrl!); // Gọi hàm xem hình ảnh lớn
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.memory(
                    base64Decode(message.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (message.videoUrl != null)
            GestureDetector(
              onTap: () {
                _playReceivedVideo(message.videoUrl!);
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Received video'),
              ),
            ),
        ],
      ),
    );
  }
}
