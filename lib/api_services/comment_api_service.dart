import 'dart:convert';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CommentApiService {
  Future<List<PhanHoi>> addBinhLuan({
    required String baivietId,
    required String userId,
    required String binhLuan,
  }) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/baiviet/addBinhLuan/$baivietId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'BinhLuan': binhLuan}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);

        if (responseData != null && responseData is List) {
          List<PhanHoi> updatedComments =
              (responseData).map((data) => PhanHoi.fromJson(data)).toList();
          return updatedComments;
        } else {
          throw Exception(
              'API response does not contain a valid list of comments');
        }
      } else {
        throw Exception('Unable to add comment');
      }
    } catch (e) {
      throw Exception('Error when adding comment: $e');
    }
  }

   Future<bool> updateComment({
    required String baivietId,
    required String binhLuanId,
    required String updatedComment,
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/updateBinhLuan/$baivietId/$binhLuanId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'BinhLuan': updatedComment}),
      );

      if (response.statusCode == 201) {
        print('Comment updated successfully');
        return true;
      } else {
        print('Failed to update comment: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error updating comment: $error');
      return false;
    }
  }

   Future<bool> deleteBinhLuan({required String baivietId, required String binhLuanId}) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/deleteBinhLuan/$baivietId/$binhLuanId');
    
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Comment deleted successfully');
        return true;
      } else {
        print('Failed to delete comment: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

}
