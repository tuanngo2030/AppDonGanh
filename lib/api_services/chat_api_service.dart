import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ChatApiService{
   Future<Map<String, dynamic>?> createConversation(String senderId, String receiverId) async {
  String apiUrl = "${dotenv.env['API_URL']}/chatsocket/Createconversation";
  try {
    Map<String, String> body = {
      'sender_id': senderId,
      'receiver_id': receiverId,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Conversation created: $data');
      return data; // Trả về toàn bộ dữ liệu, bao gồm receiverData
    } else {
      print('Failed to create conversation: ${response.body}');
      return null;
    }
  } catch (error) {
    print('Error: $error');
    return null;
  }
}

  // Phương thức lấy danh sách cuộc trò chuyện theo ID
  Future<void> getListConversation(String conversationId) async {
    String apiUrl = "${dotenv.env['API_URL']}/chatsocket/getlistconversation/";

    try {
      final response = await http.get(
        Uri.parse('$apiUrl$conversationId'), // Nối conversationId vào URL
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversations = jsonDecode(response.body);
        print('List of conversations: $conversations');
        // Xử lý danh sách cuộc trò chuyện ở đây (có thể trả về hoặc lưu trữ)
      } else {
        print('Failed to get list of conversations: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

Future<String?> uploadFile(File file, String type, void Function(double) onProgress) async {
  try {
    // API endpoint
    String endpoint = '${dotenv.env['API_URL']}/user/upload_ImageOrVideo';
    var request = http.MultipartRequest('POST', Uri.parse(endpoint));

    // Detect MIME type
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mimeComponents = mimeType.split('/');

    // Validate MIME type based on the `type` (image or video)
    if ((type == 'image' && !mimeType.startsWith('image/')) ||
        (type == 'video' && !mimeType.startsWith('video/'))) {
      throw Exception('Invalid file type: $mimeType');
    }

    // Attach file with correct MIME type
    request.files.add(
      await http.MultipartFile.fromPath(
        type == 'image' ? 'image' : 'video', // API expects 'image' or 'video'
        file.path,
        contentType: MediaType(mimeComponents[0], mimeComponents[1]), // Add MIME type
      ),
    );

    // Add additional fields
    request.fields['type'] = type;

    // Track upload progress
    final fileLength = await file.length();
    int bytesUploaded = 0;

    // Send request
    final streamResponse = await request.send();

    // Handle progress and response
    final responseBytes = <int>[]; // To collect response bytes
    Completer<String?> completer = Completer(); // Completer for async return

    streamResponse.stream.listen(
      (chunk) {
        bytesUploaded += chunk.length;
        responseBytes.addAll(chunk); // Collect response bytes
        double progress = bytesUploaded / fileLength;
        onProgress(progress); // Notify progress
      },
      onDone: () {
        // Decode the response from collected bytes
        final responseBody = utf8.decode(responseBytes);
        final jsonResponse = jsonDecode(responseBody);

        // Extract URL
        final url = (type == 'image') ? jsonResponse['imageUrl'] : jsonResponse['videoUrl'];
        if (url != null && url.startsWith('http')) {
          completer.complete(url); // Resolve the completer with URL
        } else {
          completer.completeError('Invalid URL received: $url');
        }
      },
      onError: (error) {
        completer.completeError('Error during upload: $error'); // Handle errors
      },
    );

    return completer.future; // Return the result from completer
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}

// Future<String?> uploadFile(File file, String type) async {
//   try {
//     String endpoint = '${dotenv.env['API_URL']}/user/upload_ImageOrVideo';
//     var request = http.MultipartRequest('POST', Uri.parse(endpoint));

//     // Thêm file vào request
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         type == 'image' ? 'image' : 'video', // Tên field tương ứng với loại file
//         file.path, // Đường dẫn tới file cần upload
//       ),
//     );

//     request.fields['type'] = type;

//     // Gửi yêu cầu và nhận phản hồi
//     final response = await request.send();
    
//     if (response.statusCode == 200) {
//       // Xử lý phản hồi từ server
//       final responseData = await http.Response.fromStream(response);
//       print('Response data: ${responseData.body}');

//       // Parse JSON từ phản hồi
//       final jsonResponse = jsonDecode(responseData.body);
//       print('JSON Response: $jsonResponse');

//       // Truy xuất URL ảnh hoặc video từ phản hồi
//       String? url;
//       if (type == 'image') {
//         url = jsonResponse['imageUrl']; // Kiểm tra trường này
//       } else {
//         url = jsonResponse['videoUrl']; // Kiểm tra trường này
//       }

//       // Kiểm tra nếu URL hợp lệ (URL phải bắt đầu bằng http hoặc https)
//       if (url != null && url.startsWith('http')) {
//         return url; // Trả về URL hợp lệ
//       } else {
//         print('Invalid URL received: $url');
//         return null;
//       }
//     } else {
//       print('Upload failed with status code: ${response.statusCode}');
//       // print('Response body: ${response.body}');
//       return null;
//     }
//   } catch (e) {
//     print('Error uploading file: $e');
//     return null;
//   }
// }


}