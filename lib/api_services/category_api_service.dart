import 'package:don_ganh_app/models/categories_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryApiService {
  final String apiUrl = "${dotenv.env['API_URL']}/danhmuc/getlistDanhMuc";
     
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List Category = json.decode(response.body);
      return Category.map((category) => CategoryModel.fromJSON(category))
          .toList();
    } else {
      throw Exception('Failed to fetch categories');
    }
  }
}
