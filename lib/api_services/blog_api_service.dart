import 'dart:convert';
import 'dart:io';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<BlogModel>> getListBaiViet(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/getListBaiViet/$userId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => BlogModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blog posts');
    }
  }

  Future<List<BlogModel>> getListBaiVietByUserId(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/getBaiVietById/$userId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => BlogModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blog posts');
    }
  }

  Future<List<BlogModel>> getListBaiVietTheoDoi(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/getListBaiVietTheoDoi/$userId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => BlogModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load followed blog posts');
    }
  }

  Future<String> createBaiViet({
    required String userId,
    String? tieude,
    required String noidung,
    List<String>? tags,
    List<File>? imageFiles,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/createBaiViet');
    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['userId'] = userId;
    if (tieude != null) request.fields['tieude'] = tieude;
    request.fields['noidung'] = noidung;
    if (tags != null && tags.isNotEmpty) {
      request.fields['tags'] = tags.join(',');
    }
    if (imageFiles != null) {
      for (var file in imageFiles) {
        var fileExtension = file.path.split('.').last.toLowerCase();
        var mimeType = 'image/jpeg';
        if (fileExtension == 'png') mimeType = 'image/png';
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      return responseData.body;
    } else {
      throw Exception('Failed to create blog post');
    }
  }

  Future<void> updateLike(String baivietId, String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/updateLike/$baivietId/$userId');
    final response = await http.put(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to update like');
    }
  }

  Future<void> deleteBaiViet(String baivietId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/deleteBaiViet/$baivietId');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete blog post');
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
    final token = await _getToken();
    if (token == null) throw Exception('Token not found. Please log in again.');

    final url = Uri.parse('${dotenv.env['API_URL']}/baiviet/updateBaiViet/$baivietId');
    var request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['tieude'] = tieude!;
    request.fields['tags'] = tags;
    request.fields['noidung'] = noidung;
    request.fields['userId'] = userId;

    if (files != null) {
      for (var file in files) {
        var fileExtension = file.path.split('.').last.toLowerCase();
        var mimeType = 'image/jpeg';
        if (fileExtension == 'png') mimeType = 'image/png';
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to update blog post');
    }
  }
}
