import 'package:don_ganh_app/models/categories_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryApiService {
  final String apiUrl = "https://imp-model-widely.ngrok-free.app/api/danhmuc/getlistDanhMuc";
     
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
