import 'package:don_ganh_app/models/variant_model.dart';

class CartModel {
  final String id;
  // final UserModel user;
  final List<ChiTietGioHang> chiTietGioHang;

  CartModel({
    required this.id,
    // required this.user,
    required this.chiTietGioHang,
  });

  factory CartModel.fromJSON(Map<String, dynamic> data) {
    var chiTietGioHangFromJson = data['chiTietGioHang'] as List<dynamic>;
    List<ChiTietGioHang> listCart = chiTietGioHangFromJson
        .map((item) => ChiTietGioHang.fromJSON(item))
        .toList();

    return CartModel(
      id: data['_id'],
      // user: UserModel.fromJSON(data['userId']),
      chiTietGioHang: listCart,
    );
  }

}

class ChiTietGioHang {
  final String id;
  final VariantModel variantModel;
  final int soLuong;
  final double donGia;

  ChiTietGioHang({
    required this.id,
    required this.variantModel,
    required this.soLuong,
    required this.donGia,
  });

  factory ChiTietGioHang.fromJSON(Map<String, dynamic> data) {
    return ChiTietGioHang(
      id: data['_id'],
      variantModel: VariantModel.fromJSON(data['idBienThe']),
      soLuong: data['soLuong'],
      donGia: data['donGia'],
    );
  }
}