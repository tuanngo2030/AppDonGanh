import 'dart:convert';
import 'dart:io';
import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/models/chat_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
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
  final Map<String, dynamic>? receiverData; // Thêm receiverData
  final ProductModel productModel;
  final String token;

  const ChatScreen({
    super.key,
    required this.title,
    required this.userId,
    required this.conversationId,
    this.receiverData, // Nhận dữ liệu receiver
    required this.productModel,
    required this.token,
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
  double _uploadProgress = 0.0;
  @override
  void initState() {
    super.initState();
    _loadTokenAndConnect();
    _controller.text = widget.productModel.nameProduct;
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

  // Function to clear selected image
  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  // Clear selected video
  void _clearVideo() {
    setState(() {
      _video = null;
      _videoController?.dispose();
      _videoController = null;
    });
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
      final compressedVideo = (_video!);
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

  Future<void> _loadTokenAndConnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {
      print('user $token');
      connect();
    } else {
      print("Token not found");
    }
  }

  void connect() {
      setState(() {
    _isLoading = true; // Bắt đầu trạng thái loading
  });
    // Kiểm tra nếu socket đã tồn tại và đang kết nối thì không cần tạo kết nối mới
    if (socket != null && socket!.connected) {
      print("Socket is already connected.");
      return;
    }
    if (socket != null && socket!.connected) {
      // Hủy các sự kiện và ngắt kết nối socket
      socket!.off('Joined');
      socket!.off('message');
      socket!.off('error');
      socket!.off('disconnect');
      socket!.off('reconnect');
      socket!.disconnect();
      socket = null; // Giải phóng socket để chuẩn bị tạo kết nối mới
    }

    // Tạo socket mới với các cấu hình kết nối ổn định hơn
    socket = IO.io(
      "${dotenv.env['API_SOCKET_URL']}",
      <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": true,
        "reconnection": true,
        "reconnectionAttempts": 1, // Số lần thử kết nối lại tối đa
        "reconnectionDelay": 5000, // Độ trễ giữa các lần thử kết nối lại
        'auth': {
          'token': token,
        }
      },
    );

    socket!.connect();

    // Thêm các sự kiện sau khi socket được kết nối
    socket!.onConnect((_) {
      print("Connected to the server with token: $token");
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
          id: data['message']['_id'] ?? '',
          text: data['message']['text'] ?? '',
          seen: false,
          msgByUserId: data['message']['msgByUserId'] ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageUrl: data['message']['imageUrl'],
          videoUrl: data['message']['videoUrl'],
        );

        // Thêm tin nhắn vào danh sách nếu nó chưa tồn tại
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
      setState(() {
    _isLoading = false; // Kết thúc trạng thái loading
  });
  }

  // void connect() {
  //   if (socket != null && socket!.connected) {
  //     // Hủy các sự kiện và ngắt kết nối socket
  //     socket!.off('Joined');
  //     socket!.off('message');
  //     socket!.off('error');
  //     socket!.off('disconnect');
  //     socket!.off('reconnect');
  //     // socket!.disconnect();
  //     socket = null; // Giải phóng socket để chuẩn bị tạo kết nối mới
  //     socket!.disconnect();
  //     socket!.clearListeners(); // Clear all previous listeners
  //   }

  //   // Tạo socket mới
  //   socket = IO.io(
  //     "${dotenv.env['API_SOCKET_URL']}",
  //     <String, dynamic>{
  //       "transports": ["websocket"],
  //       "autoConnect": true,
  //       "reconnection": true,
  //       'auth': {
  //         'token': token,
  //       }
  //     },
  //   );

  //   socket!.connect();

  //   // Thêm các sự kiện sau khi socket được kết nối
  //   socket!.onConnect((_) {
  //     print("Connected to the server with token: $token");
  //     socket!.emit("join", {
  //       'token': token,
  //       'conversationId': widget.conversationId,
  //     });
  //   });

  //   socket!.on('Joined', (data) {
  //     List<dynamic> previousMessages = data['messages'];
  //     for (var msg in previousMessages) {
  //       addMessage(Message.fromJson(msg));
  //     }

  //     print("Joined conversation with messages: $data");
  //   });

  //   socket!.on('message', (data) {
  //     if (data != null && data['message'] != null) {
  //       final message = Message(
  //         id: data['message']['_id'] ??
  //             '', // Sử dụng giá trị mặc định nếu không có
  //         text: data['message']['text'] ?? '',
  //         seen: false,
  //         msgByUserId: data['message']['msgByUserId'] ?? '', // Kiểm tra giá trị
  //         createdAt:
  //             DateTime.now(), // Sử dụng thời gian hiện tại hoặc lấy từ server
  //         updatedAt: DateTime.now(), // Tương tự
  //         imageUrl: data['message']['imageUrl'], // Thêm imageUrl nếu có
  //         videoUrl: data['message']['videoUrl'], // Thêm videoUrl nếu có
  //       );

  //       // Thêm tin nhắn vào danh sách
  //       if (!messages.any((msg) => msg.id == message.id)) {
  //         addMessage(message);
  //       }
  //     } else {
  //       print('Received null data: $data');
  //     }
  //   });

  //   socket!.on('error', (data) {
  //     print('Error: ${data['message']}');
  //   });

  //   socket!.onDisconnect((_) {
  //     print("Disconnected from the server");
  //     // Clear the token from the socket
  //   });

  //   socket!.onReconnect((_) {
  //     print("Reconnected to the server");
  //     socket!.emit("join", {
  //       'token': token,
  //       'conversationId': widget.conversationId,
  //     });
  //   });
  // }

  // Hàm để chuyển đổi tệp thành base64
  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  void sendMessage(String text) async {

      setState(() {
    _isLoading = true; // Bắt đầu trạng thái loading
  });
    if (!mounted || text.isEmpty && _image == null && _video == null) return;

    if (socket != null && socket!.connected) {
      String? imageUrl;
      String? videoUrl;

      setState(() => _isLoading = true);

      if (_image != null) {
        imageUrl =
            await ChatApiService().uploadFile(_image!, 'image', (progress) {
          // setState(() => _uploadProgress = progress); // Cập nhật tiến trình ảnh
        });
        if (imageUrl == null) {
          print("Failed to upload image");
          setState(() => _isLoading = false);
          return;
        }
      }

      if (_video != null) {
        videoUrl =
            await ChatApiService().uploadFile(_video!, 'video', (progress) {
          // setState(
          //     () => _uploadProgress = progress); // Cập nhật tiến trình video
        });
        if (videoUrl == null) {
          print("Failed to upload video");
          setState(() => _isLoading = false);
          return;
        }
      }

      socket!.emit('sendMessage', {
        'conversationId': widget.conversationId,
        'text': text,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        if (text == widget.productModel.nameProduct)
          'IDSanPham': widget.productModel.id,
        'token': token,
      });

      _controller.clear();
      setState(() {
        _image = null;
        _video = null;
        _videoController?.dispose();
        _videoController = null;
        _isLoading = false;
        _uploadProgress = 0.0; // Đặt lại tiến trình tải
      });
    } else {
      print("Socket is not connected.");
    }
  }

  // void sendMessage(String text) async {
  //   if (!mounted || text.isEmpty && _image == null && _video == null) return;

  //   if (socket != null && socket!.connected) {
  //     String? imageUrl;
  //     String? videoUrl;

  //     // Nếu có hình ảnh, tải lên và lấy URL
  //     if (_image != null) {
  //       imageUrl = await ChatApiService().uploadFile(_image!, 'image');
  //       if (imageUrl == null) {
  //         print("Failed to upload image");
  //         return;
  //       }
  //     }

  //     // Nếu có video, tải lên và lấy URL
  //     if (_video != null) {
  //       videoUrl = await ChatApiService().uploadFile(_video!, 'video');
  //       if (videoUrl == null) {
  //         print("Failed to upload video");
  //         return;
  //       }
  //     }

  //     bool sendWithProductId = text == widget.productModel.nameProduct;

  //     // Tạo tin nhắn mới và gửi tới server
  //     socket!.emit('sendMessage', {
  //       'conversationId': widget.conversationId,
  //       'text': text,
  //       'imageUrl': imageUrl,
  //       'videoUrl': videoUrl,
  //       if (sendWithProductId) 'IDSanPham': widget.productModel.id,
  //       'token': token,
  //     });

  //     // Xóa dữ liệu sau khi gửi tin nhắn
  //     _controller.clear();
  //     setState(() {
  //       _image = null;
  //       _video = null;
  //       _videoController?.dispose();
  //       _videoController = null;
  //       _isLoading = false;
  //     });
  //   } else {
  //     print("Socket is not connected.");
  //   }
  // }

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
    body: Stack(
      children: [
        SafeArea(
          child: Column(
            children: <Widget>[
              // Header với avatar và thông tin người nhận
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Color.fromRGBO(41, 87, 35, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Color.fromRGBO(41, 87, 35, 1)),
                        ),
                      ),
                      const SizedBox(width: 30),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            widget.receiverData?['anhDaiDien'] != null
                                ? NetworkImage(widget.receiverData!['anhDaiDien'])
                                : null,
                        radius: 20,
                        child: widget.receiverData?['anhDaiDien'] == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      if (widget.receiverData != null)
                        Text(
                          widget.receiverData!['tenNguoiDung'] ?? 'Unknown User',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),

              // Danh sách sản phẩm và tin nhắn
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length + 1, // Sản phẩm + tin nhắn
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Hiển thị sản phẩm ở đầu danh sách
                        return _buildProductWidget();
                      } else {
                        // Hiển thị tin nhắn
                        final message = messages[index - 1];
                        return _buildMessage(message);
                      }
                    },
                  ),
                ),
              ),

              // Vùng nhập tin nhắn
              _buildInputArea(),
            ],
          ),
        ),

        // Hiển thị hiệu ứng tải khi _isLoading là true
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(59, 99, 53, 1)),
              ),
            ),
          ),
      ],
    ),
  );
}


  Widget _buildMessage(Message message) {
    String formattedTime = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          if (message.imageUrl != null)
            GestureDetector(
              onTap: () {
                _showFullImage(message.imageUrl!);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.network(
                    message.imageUrl!,
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
                width: 150,
                child: VideoPlayerWidget(videoUrl: message.videoUrl!),
              ),
            ),
          if (message.IDSanPham != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Row(
                  children: [
                    // Display product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        message.IDSanPham!.imageProduct,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Display product name and a brief description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.IDSanPham!.nameProduct,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.IDSanPham!.moTa,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display image preview if an image is selected
          if (_image != null)
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _clearImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Display video preview if a video is selected
          if (_video != null)
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  width: 100,
                  height: 100,
                  child: AspectRatio(
                    aspectRatio: _videoController?.value.aspectRatio ?? 1.0,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _clearVideo,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Row(
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
        ],
      ),
    );
  }

  Widget _buildProductWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Container(
        // padding: const EdgeInsets.all(10),
        // margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 220, 218, 218)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.productModel.imageProduct,
                          ),
                          fit: BoxFit.cover,
                        ),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productModel.nameProduct ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(41, 87, 35, 1),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$${widget.productModel.donGiaBan ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey, // Màu của viền
                      width: 1.0, // Độ dày của viền
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Chi tiết',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(41, 87, 35, 1), fontSize: 15),
                  ),
                ),
              ),
            )
          ],
        ),
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
                          child: SizedBox(
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
