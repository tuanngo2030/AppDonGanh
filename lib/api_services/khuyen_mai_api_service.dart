import 'dart:convert';
import 'package:don_ganh_app/models/khuyen_mai_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Service for fetching promotions
class KhuyenMaiApiService {
  Future<List<KhuyenMaiModel>> fetchPromotionList(int tongtien) async {
    final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/khuyenmai/getlistKhuyenMai/$tongtien'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => KhuyenMaiModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load promotion list');
    }
  }
}

