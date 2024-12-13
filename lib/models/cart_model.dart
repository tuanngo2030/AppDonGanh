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
    return CartModel(
      id: data['gioHangId'] ?? '',
      user: NguoiDung.fromJson(data['user'] as Map<String, dynamic>),
      mergedCart: (data['mergedCart'] as List<dynamic>?)
              ?.map(
                  (item) => SanPhamCart.fromJSON(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

   @override
  String toString() {
    return 'CartModel(id: $id, user: $user, mergedCart: $mergedCart)';
  }

  Map<String, dynamic> toJson() {
    return {
      'gioHangId': id,
      'user': user.toJson(),
      'mergedCart': mergedCart.map((item) => item.toJson()).toList(),
    };
  }
}

class SanPhamCart {
  final NguoiDung user;
  final List<SanPhamList> sanPhamList;
  double? giaTriKhuyenMai; // Số tiền khuyến mãi cho user này

  SanPhamCart({
    required this.user,
    required this.sanPhamList,
    this.giaTriKhuyenMai,
  });

  factory SanPhamCart.fromJSON(Map<String, dynamic> data) {
    return SanPhamCart(
      user: NguoiDung.fromJson(data['user'] as Map<String, dynamic>),
      
      sanPhamList: (data['sanPhamList'] as List<dynamic>?)
              ?.map(
                  (item) => SanPhamList.fromJSON(item as Map<String, dynamic>))
              .toList() ??
          [],
        giaTriKhuyenMai: data['SoTienKhuyenMai'],
    );
  }

    @override
  String toString() {
    return 'SanPhamCart(user: $user, sanPhamList: $sanPhamList, giaTriKhuyenMai: $giaTriKhuyenMai)';
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'sanPhamList': sanPhamList.map((item) => item.toJson()).toList(),
      'giaTriKhuyenMai': giaTriKhuyenMai,
    };
  }
}


class SanPhamList {
  final NguoiDung user;
  final ProductModel sanPham;
  final List<ChiTietGioHang> chiTietGioHangs;

  SanPhamList({
    required this.user,
    required this.sanPham,
    required this.chiTietGioHangs,
  });

  factory SanPhamList.fromJSON(Map<String, dynamic> data) {
    return SanPhamList(
      user: NguoiDung.fromJson(data['userId'] as Map<String, dynamic>),
      sanPham: ProductModel.fromJSON(data['sanPham'] as Map<String, dynamic>),
      chiTietGioHangs: (data['chiTietGioHang'] as List<dynamic>?)
          ?.map((item) => ChiTietGioHang.fromJSON(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

   @override
  String toString() {
    return 'SanPhamList(user: $user, sanPham: $sanPham, chiTietGioHangs: $chiTietGioHangs)';
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'sanPham': sanPham.toJson(),
      'chiTietGioHangs': chiTietGioHangs.map((item) => item.toJson()).toList(),
    };
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
      variantModel:
          VariantModel.fromJSON(data['idBienThe'] as Map<String, dynamic>),
      soLuong: data['soLuong'] ?? 0,
      donGia: data['donGia'] ?? 0,
    );
  }

    @override
  String toString() {
    return 'ChiTietGioHang(id: $id, variantModel: $variantModel, soLuong: $soLuong, donGia: $donGia)';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'idBienThe': variantModel.toJson(),
      'soLuong': soLuong,
      'donGia': donGia,
    };
  }
}