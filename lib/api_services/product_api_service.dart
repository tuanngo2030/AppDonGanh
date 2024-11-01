import 'dart:convert';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProductApiService {
  final String apiUrl = "${dotenv.env['API_URL']}/sanpham";

  Future<List<ProductModel>> getListProduct() async {
    final response = await http.get(Uri.parse('$apiUrl/getlistSanPham'));

    if (response.statusCode == 200) {
      List ProductResponse = json.decode(response.body);
      return ProductResponse.map((json) => ProductModel.fromJSON(json))
          .toList();
    } else {
      throw Exception("Failed to load product list");
    }
  }

  Future<ProductModel> getProductByID(String productID) async {
    final response =
        await http.get(Uri.parse('$apiUrl/findSanPhambyID/$productID'));

    if (response.statusCode == 200) {
      var productResponse = json.decode(response.body);
      return ProductModel.fromJSON(productResponse);
    } else {
      throw Exception("Failed to load product details");
    }
  }

  Future<Map<String, dynamic>> getProducts(int page, {int limit = 5}) async {
    final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/sanpham/getlistPageSanPham/$page?limit=$limit'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
