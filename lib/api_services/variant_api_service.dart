import 'dart:convert';
import 'package:don_ganh_app/models/variant_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VariantApiService {
  final String url = "${dotenv.env['API_URL']}/sanpham/getlistBienThe/";
  Future<List<VariantModel>> getVariant(String idProduct) async {
    final response = await http.get(Uri.parse('$url$idProduct'));

    if(response.statusCode == 200) {
     List Variant = json.decode(response.body);
      return Variant.map((variant) => VariantModel.fromJSON(variant))
          .toList();
    }else{
      throw Exception('Failed to load variants');
    }

  }
}