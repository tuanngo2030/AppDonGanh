import 'package:don_ganh_app/models/banner_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BannerApiService {
  final String apiUrl = "${dotenv.env['API_URL']}/banner/banners?";

  Future<List<BannerModel>> fetchBanner() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List BannerResponse = json.decode(response.body);
      return BannerResponse.map((image) => BannerModel.fromJSON(image)).toList();
    }else{
      throw Exception('Failed to load banner data');
    }
  }
}
