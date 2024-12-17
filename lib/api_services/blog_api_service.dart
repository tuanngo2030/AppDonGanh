import 'dart:convert';
import 'dart:io';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BlogApiService {
  // Replace with actual URL

  Future<List<BlogModel>> getListBaiViet(String userId) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/baiviet/getListBaiViet/$userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print('$jsonData');
        return jsonData.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load blog posts');
      }
    } catch (e) {
      print('Error fetching blog posts: $e');
      rethrow;
    }
  }

  Future<List<BlogModel>> getListBaiVietByUserId(String userId) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/baiviet/getBaiVietById/$userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load blog posts');
      }
    } catch (e) {
      print('Error fetching blog posts: $e');
      rethrow;
    }
  }

  Future<List<BlogModel>> getListBaiVietTheoDoi(String userId) async {
    final url = Uri.parse(
        '${dotenv.env['API_URL']}/baiviet/getListBaiVietTheoDoi/$userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse JSON data into a list of BlogModel
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load followed blog posts');
      }
    } catch (e) {
      print('Error fetching followed blog posts: $e');
      rethrow;
    }
  }

  Future<String> createBaiViet({
    required String userId,
    String? tieude,
    required String noidung,
    List<String>? tags,
    List<File>? imageFiles,
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/createBaiViet');
    var request = http.MultipartRequest('POST', url);

    // Adding text fields
    request.fields['userId'] = userId;
    if (tieude != null) {
      request.fields['tieude'] = tieude; // Only add tieude if it's not null
    }
    request.fields['noidung'] = noidung;

    if (tags != null && tags.isNotEmpty) {
      request.fields['tags'] = tags.join(',');
    }

    // Adding image files with content type if not null
    if (imageFiles != null) {
      for (var file in imageFiles) {
        var fileExtension = file.path.split('.').last.toLowerCase();
        var mimeType = 'image/jpeg'; // Default to jpeg

        // Set MIME type based on file extension
        if (fileExtension == 'png') {
          mimeType = 'image/png';
        } else if (fileExtension == 'gif') {
          mimeType = 'image/gif';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(
                mimeType), // Set content type based on file extension
          ),
        );
      }
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Decode the response body into a string (since the response is now just text)
        var responseData = await http.Response.fromStream(response);
        var data = responseData.body;

        // Return the response text (e.g., "Blog post created successfully")
        return data;
      } else {
        throw Exception(
            'Failed to create blog post, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating blog post: $e');
      rethrow;
    }
  }

  Future<void> updateLike(String baivietId, String userId) async {
    final url = Uri.parse(
        '${dotenv.env['API_URL']}/baiviet/updateLike/$baivietId/$userId');

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('Like updated successfully');
      } else if (response.statusCode == 404) {
        print('Review not found');
      } else {
        print('Failed to update like: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating like: $e');
    }
  }

  Future<void> deleteBaiViet(String baivietId) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/baiviet/deleteBaiViet/$baivietId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Bài viết đã được xóa thành công');
    } else {
      throw Exception('Lỗi khi xóa bài viết: ${response.statusCode}');
    }
  }

  Future<void> updateBaiViet({
    required String baivietId,
    String? tieude,
    required String tags,
    required String noidung,
    required String userId,
    List<File>? files,
  }) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/baiviet/updateBaiViet/$baivietId');
    var request = http.MultipartRequest('PUT', url);

    // Adding text fields
    request.fields['tieude'] = tieude!;
    request.fields['tags'] = tags;
    request.fields['noidung'] = noidung;
    request.fields['userId'] = userId;

    // Adding image files with content type if not null
    if (files != null) {
      for (var file in files) {
        var fileExtension = file.path.split('.').last.toLowerCase();
        var mimeType = 'image/jpeg'; // Default MIME type (JPEG)

        // Set MIME type based on file extension
        if (fileExtension == 'png') {
          mimeType = 'image/png';
        } else if (fileExtension == 'gif') {
          mimeType = 'image/gif';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(
                mimeType), // Set content type based on file extension
          ),
        );
      }
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Update successful');
      } else {
        print('Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating post: $e');
    }
  }
}
