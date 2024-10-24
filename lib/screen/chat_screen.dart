import 'dart:convert';
import 'dart:io';
import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  bool _isLoading = false; // Biến để theo dõi trạng thái tải

  @override
  void initState() {
    super.initState();
    _loadTokenAndConnect();
  }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   _controller.dispose();
  //   socket?.disconnect();
  //   socket?.dispose();
  //   _videoController?.dispose();
  //   super.dispose();
  // }
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
              child: Image.network(
                imageUrl,
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
      });

      // Nén video trước khi sử dụng
      final compressedVideo = await (_video!);
      if (compressedVideo != null) {
        setState(() {
          _video = compressedVideo; // Cập nhật video đã được nén
          _videoController = VideoPlayerController.file(_video!)
            ..initialize().then((_) {
              setState(
                  () {}); // Rebuild the widget when the video is ready to play
              _videoController!.play(); // Auto-play the video
            });
        });
      }
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
      "${dotenv.env['API_SOCKET_URL']}",
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
        if (!messages.any((msg) => msg.id == message.id)) {
          addMessage(message);
        }
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
    if (!mounted || text.isEmpty && _image == null && _video == null) return;

    if (socket != null && socket!.connected) {
      String? imageUrl;
      String? videoUrl;

      // Nếu có hình ảnh, tải lên và lấy URL
      if (_image != null) {
        imageUrl = await ChatApiService().uploadFile(_image!, 'image');
        if (imageUrl == null) {
          print("Failed to upload image");
          return;
        }
      }

      // Nếu có video, tải lên và lấy URL
      if (_video != null) {
        videoUrl = await ChatApiService().uploadFile(_video!, 'video');
        if (videoUrl == null) {
          print("Failed to upload video");
          return;
        }
      }

      // Tạo tin nhắn mới và gửi tới server
      socket!.emit('sendMessage', {
        'conversationId': widget.conversationId,
        'text': text,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
      });

      // Xóa dữ liệu sau khi gửi tin nhắn
      _controller.clear();
      setState(() {
        _image = null;
        _video = null;
        _videoController?.dispose();
        _videoController = null;
        _isLoading = false;
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
            if (_isLoading) // Hiển thị chỉ báo tải
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(),
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
                    child:
                        VideoPlayer(_videoController!), // Display video player
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
                  width: 150,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.network(
                    (message.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (message.videoUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                height: 150,
                width: 250,
                child: VideoPlayerWidget(videoUrl: message.videoUrl!),
              ),
            ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullScreenVideoPlayer(videoUrl: widget.videoUrl),
          ),
        );
      },
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  double _volume = 1.0;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_controller.value.isPlaying;
    });
  }

  Future<void> _saveVideo() async {}

  void _setVolume(double value) {
    setState(() {
      _volume = value;
      _controller.setVolume(_volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Video"),
      ),
      body: Center(
        child: _isLoading // Kiểm tra nếu đang tải
            ? const Center(child: CircularProgressIndicator())
            : _controller.value.isInitialized
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      // Nút dừng và tiếp tục
                      Positioned(
                        bottom: 10,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                          ],
                        ),
                      ),
                      // Nút tải video ở góc trên bên phải
                      // Positioned(
                      //   top: 20,
                      //   right: 20,
                      //   child: IconButton(
                      //     icon: const Icon(
                      //       Icons.download,
                      //       color: Colors.white,
                      //     ),
                      //     onPressed: _saveVideo, // Lưu video
                      //   ),
                      // ),
                      // Slider điều chỉnh âm thanh ở góc dưới bên phải
                      Positioned(
                        bottom: 10,
                        right: 20,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Container(
                            height: 40,
                            child: Slider(
                              value: _volume,
                              onChanged: _setVolume,
                              min: 0,
                              max: 1,
                              activeColor: Colors.white,
                              inactiveColor: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(child: Text("Video không thể phát!")),
      ),
    );
  }
}
