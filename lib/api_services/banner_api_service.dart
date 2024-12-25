import 'dart:convert';
import 'package:don_ganh_app/models/banner_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BannerApiService {
  final String apiUrl = "${dotenv.env['API_URL']}/banner/banners?";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

 Future<List<BannerModel>> fetchBanner() async {
  final token = await _getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Token not found. Please log in again.');
  }

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    // Assuming the API returns a map with a key "banners"
    Map<String, dynamic> bannerResponse = json.decode(response.body);

    // Check if the "banners" key exists and contains a list
    if (bannerResponse.containsKey('banners')) {
      List<dynamic> banners = bannerResponse['banners'];
      return banners.map((image) => BannerModel.fromJSON(image)).toList();
    } else {
      throw Exception('No banners found in the response');
    }
  } else {
    throw Exception('Failed to load banner data');
  }
}

}
