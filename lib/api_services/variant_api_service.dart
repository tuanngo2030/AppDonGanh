import 'dart:convert';
import 'package:don_ganh_app/models/variant_model.dart';
import 'package:http/http.dart' as http;

class VariantApiService {
  final String url = "https://imp-model-widely.ngrok-free.app/api/sanpham/getlistBienTheInSanPham66c6a34e579ba1559e756827";
  Future<List<VariantModel>> getVariant() async {
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200) {
     List Variant = json.decode(response.body);
      return Variant.map((variant) => VariantModel.fromJSON(variant))
          .toList();
    }else{
      throw Exception('Failed to load variants');
    }

  }
}