import 'dart:io';

import 'package:don_ganh_app/models/review_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReviewApiService {
   final String baseUrl = 'https://peacock-wealthy-vaguely.ngrok-free.app/api';
   String? userId;
    
  // Method to fetch reviews for a specific product
  Future<List<DanhGia>> getReviewsByProductId(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    final url = Uri.parse('$baseUrl/danhgia/getListDanhGiaInSanPhamById/$productId/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((json) => DanhGia.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

   Future<void> createReview({
    required String userId,
    required String sanphamId,
    required int xepHang,
    required String binhLuan,
    File? imageFile, // Optional image file
  }) async {
    final url = Uri.parse('$baseUrl/danhgia/createDanhGia');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add the fields for the review
    request.fields['userId'] = userId;
    request.fields['sanphamId'] = sanphamId;
    request.fields['XepHang'] = xepHang.toString();
    request.fields['BinhLuan'] = binhLuan;

    // If there's an image file, add it to the request
    if (imageFile != null) {
      var fileStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'file', 
        fileStream,
        length,
        filename: imageFile.path, // Use the file name from path
      );
      request.files.add(multipartFile);
    }

    try {
      // Send the request
      var response = await request.send();

      // Get the response status code
      if (response.statusCode == 201) {
        print('Review created successfully');
      } else {
        print('Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  Future<void> deleteReview(String spId,String reviewId) async {
  final url = Uri.parse('$baseUrl/danhgia/deleteDanhGia/$spId/$reviewId'); // Adjust the endpoint if necessary
  try {
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      print('Review deleted successfully');
    } else {
      print('Failed to delete review: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error deleting review: $e');
  }
}

  Future<void> updateReview({
    required String danhGiaId,
    required int xepHang,
    required String binhLuan,
  }) async {
    final url = Uri.parse('$baseUrl/danhgia/updateDanhGia/$danhGiaId');

    try {
      // Create a PUT request with JSON body
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'XepHang': xepHang,
          'BinhLuan': binhLuan,
        }),
      );

      if (response.statusCode == 200) {
        print('Review updated successfully');
      } else {
        print('Failed to update review: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating review: $e');
    }
  }

 Future<void> updateLike(String phanHoiId, String userId) async {
    final url = Uri.parse('$baseUrl/danhgia/updateLike/$phanHoiId/$userId');

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

}