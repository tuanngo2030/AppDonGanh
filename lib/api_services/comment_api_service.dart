import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CommentApiService {

  Future<void> addBinhLuan({
  required String baivietId,
  required String userId,
  required String binhLuan,
}) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/addBinhLuan/$baivietId');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'BinhLuan': binhLuan,
      }),
    );

    if (response.statusCode == 201) {
      print('Bình luận đã được thêm thành công');
    } else {
      print('Lỗi: ${response.statusCode}');
      throw Exception('Không thể thêm bình luận');
    }
  } catch (e) {
    print('Lỗi khi thêm bình luận: $e');
    throw Exception('Đã xảy ra lỗi khi thêm bình luận');
  }
}
  
}

