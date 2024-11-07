import 'package:don_ganh_app/models/product_model.dart';

class FavoriteModel {
  String? id;
  List<ProductModel>? sanPhams;

  FavoriteModel({this.id, this.sanPhams});

  // Convert from JSON to model
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['_id'] as String?,
      sanPhams: (json['sanphams'] as List<dynamic>?)
          ?.map((item) => ProductModel.fromJSON(item['IDSanPham'] as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert from model to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sanphams': sanPhams?.map((item) => item.toJson()).toList(),
    };
  }
}

class FavoriteModelNoPopulate {
  final String id;
  final List<FavoriteProduct> sanPhams;

  FavoriteModelNoPopulate({
    required this.id,
    required this.sanPhams,
  });

  factory FavoriteModelNoPopulate.fromJson(Map<String, dynamic> json) {
    var sanPhamsFromJson = json['sanphams'] as List;
    List<FavoriteProduct> sanPhamsList =
        sanPhamsFromJson.map((i) => FavoriteProduct.fromJson(i)).toList();

    return FavoriteModelNoPopulate(
      id: json['_id'],
      sanPhams: sanPhamsList,
    );
  }
}

class FavoriteProduct {
  final String idSanPham;
  final String id;

  FavoriteProduct({
    required this.idSanPham,
    required this.id,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      idSanPham: json['IDSanPham'],
      id: json['_id'],
    );
  }
}