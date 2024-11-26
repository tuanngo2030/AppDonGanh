import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';

class CartModel {
  final String id;
  final NguoiDung user;
  final List<SanPhamCart> mergedCart;

  CartModel({
    required this.id,
    required this.user,
    required this.mergedCart,
  });

  factory CartModel.fromJSON(Map<String, dynamic> data) {
    // Print the entire response data for debugging
    print('CartModel.fromJSON data: $data');

    // Safely extract 'mergedCart' and handle null/empty cases
    var mergedCartFromJson = data['mergedCart'];
    if (mergedCartFromJson == null) {
      throw Exception("mergedCart is null or missing");
    }

    List<SanPhamCart> listCart = [];
    if (mergedCartFromJson is List) {
      // Map each element to a SanPhamCart object
      listCart = mergedCartFromJson
          .map((item) => SanPhamCart.fromJSON(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          "Expected mergedCart to be a list, but got: ${mergedCartFromJson.runtimeType}");
    }

    // Safely extract 'user' data and ensure it's not null
    var userData = data['user'];
    if (userData == null) {
      throw Exception("User data is null or missing");
    }

    // Ensure 'id' is correctly retrieved, fall back to an empty string if not present
    String cartId = data['gioHangId'] ?? '';

    return CartModel(
      id: cartId,
      user: NguoiDung.fromJson(userData as Map<String, dynamic>),
      mergedCart: listCart,
    );
  }
}

class SanPhamCart {
  final ProductModel sanPham;
  final List<ChiTietGioHang> chiTietGioHang;

  SanPhamCart({
    required this.sanPham,
    required this.chiTietGioHang,
  });

  factory SanPhamCart.fromJSON(Map<String, dynamic> data) {
    var chiTietFromJson = data['chiTietGioHang'];
    List<ChiTietGioHang> listChiTiet = [];

    if (chiTietFromJson is List) {
      // If it's a list, we check if each item is a Map<String, dynamic>
      listChiTiet = chiTietFromJson
          .whereType<Map<String, dynamic>>() // Ensures each item is a Map
          .map((item) => ChiTietGioHang.fromJSON(item))
          .toList();
    } else if (chiTietFromJson is Map) {
      // If it's a map, we convert it to a single item list
      listChiTiet = [
        ChiTietGioHang.fromJSON(chiTietFromJson as Map<String, dynamic>)
      ];
    } else {
      throw Exception('Unexpected data type for chiTietGioHang');
    }

    return SanPhamCart(
      sanPham: data['sanPham'] != null
          ? ProductModel.fromJSON(data['sanPham'] as Map<String, dynamic>)
          : throw Exception('SanPham data is null'),
      chiTietGioHang: listChiTiet,
    );
  }
}


class ChiTietGioHang {
  final String id;
  final VariantModel variantModel;
  int soLuong;
  final int donGia;

  ChiTietGioHang({
    required this.id,
    required this.variantModel,
    required this.soLuong,
    required this.donGia,
  });

  factory ChiTietGioHang.fromJSON(Map<String, dynamic> data) {
    return ChiTietGioHang(
      id: data['_id'] ?? '',
      variantModel: _parseVariantModel(data['idBienThe']),
      soLuong: data['soLuong'] ?? 0,
      donGia: data['donGia'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'KetHopThuocTinh': variantModel.toJson(),
      'soLuong': soLuong,
      'donGia': donGia,
    };
  }

  // Helper method to handle different types for 'KetHopThuocTinh'
  static VariantModel _parseVariantModel(dynamic data) {
    if (data == null) {
      // Handle null case if KetHopThuocTinh is null
      throw Exception('KetHopThuocTinh is null');
    } else if (data is Map<String, dynamic>) {
      return VariantModel.fromJSON(data);
    } else if (data is List) {
      // Handle case where it's a list, but avoid casting null as a list
      if (data.isEmpty) {
        throw Exception('KetHopThuocTinh list is empty');
      }
      return VariantModel.fromJSON(data.first as Map<String, dynamic>);
    } else {
      // Handle unexpected types
      throw Exception('KetHopThuocTinh is not of expected type Map or List');
    }
  }

}