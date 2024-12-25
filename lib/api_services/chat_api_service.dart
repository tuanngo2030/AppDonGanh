import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApiService {
  // Method to retrieve the token from SharedPreferences
  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Assuming the token is stored with the key 'token'
  }

  Future<Map<String, dynamic>?> createConversation(String senderId, String receiverId) async {
    String apiUrl = "${dotenv.env['API_URL']}/chatsocket/Createconversation";
    
    try {
      String? token = await _getToken();
      if (token == null) {
        print('No token found!');
        return null;
      }

      Map<String, String> body = {
        'sender_id': senderId,
        'receiver_id': receiverId,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Conversation created: $data');
        return data;
      } else {
        print('Failed to create conversation: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<void> getListConversation(String conversationId) async {
    String apiUrl = "${dotenv.env['API_URL']}/chatsocket/getlistconversation/";

    try {
      String? token = await _getToken();
      if (token == null) {
        print('No token found!');
        return;
      }

      final response = await http.get(
        Uri.parse('$apiUrl$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversations = jsonDecode(response.body);
        print('List of conversations: $conversations');
        // Handle the list of conversations here
      } else {
        print('Failed to get list of conversations: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<String?> uploadFile(File file, String type, void Function(double) onProgress) async {
    try {
      String endpoint = '${dotenv.env['API_URL']}/user/upload_ImageOrVideo';
      var request = http.MultipartRequest('POST', Uri.parse(endpoint));

      // Retrieve the token from SharedPreferences
      String? token = await _getToken();
      if (token == null) {
        print('No token found!');
        return null;
      }

      // Detect MIME type
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeComponents = mimeType.split('/');

      if ((type == 'image' && !mimeType.startsWith('image/')) ||
          (type == 'video' && !mimeType.startsWith('video/'))) {
        throw Exception('Invalid file type: $mimeType');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          type == 'image' ? 'image' : 'video',
          file.path,
          contentType: MediaType(mimeComponents[0], mimeComponents[1]),
        ),
      );

      request.fields['type'] = type;

      // Add the token to the request headers
      request.headers['Authorization'] = 'Bearer $token';

      final fileLength = await file.length();
      int bytesUploaded = 0;

      final streamResponse = await request.send();

      final responseBytes = <int>[];
      Completer<String?> completer = Completer();

      streamResponse.stream.listen(
        (chunk) {
          bytesUploaded += chunk.length;
          responseBytes.addAll(chunk);
          double progress = bytesUploaded / fileLength;
          onProgress(progress);
        },
        onDone: () {
          final responseBody = utf8.decode(responseBytes);
          final jsonResponse = jsonDecode(responseBody);

          final url = (type == 'image') ? jsonResponse['imageUrl'] : jsonResponse['videoUrl'];
          if (url != null && url.startsWith('http')) {
            completer.complete(url);
          } else {
            completer.completeError('Invalid URL received: $url');
          }
        },
        onError: (error) {
          completer.completeError('Error during upload: $error');
        },
      );

      return completer.future;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}
