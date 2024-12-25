import 'dart:convert';
import 'package:don_ganh_app/models/favorite_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteApiService {
  // Helper method to get the token from SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Add product to favorites
  Future<FavoriteModel> addToFavorites(String userId, String productId) async {
    final url = Uri.parse(
        '${dotenv.env['API_URL']}/yeuthich/addToFavorites/$userId/$productId');
    final token = await _getToken();

    try {
      final response = await http.put(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token here
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final favoriteModel = FavoriteModel.fromJson(data);

        // Save favorite _id to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('IDYeuThich', data['yeuThich']['_id'] ?? '');

        // Print favoriteModel to see its details
        print(favoriteModel);

        return favoriteModel;
      } else {
        throw Exception(
            'Failed to add product to favorites: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error adding product to favorites: $error');
    }
  }

  // Get list of favorite products
  Future<List<ProductModel>> getFavorites(String userId) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/yeuthich/getListYeuThich/$userId');
    final token = await _getToken();

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token here
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Extract the favorite model from the response
        if (jsonResponse.containsKey('IDYeuThich')) {
          final sanphams = jsonResponse['IDYeuThich']['sanphams'] as List<dynamic>;

          // Map the products to ProductModel
          return sanphams.map((item) {
            // Ensure 'IDSanPham' is properly parsed as a Map
            var productData = item['IDSanPham'];
            if (productData is Map<String, dynamic>) {
              return ProductModel.fromJSON(productData);
            } else {
              throw Exception('Product data is not in the expected format');
            }
          }).toList();
        } else {
          throw Exception('IDYeuThich not found in response.');
        }
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching favorites: $error');
    }
  }
}
