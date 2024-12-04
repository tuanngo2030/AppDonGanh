import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/khuyen_mai_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';

class OrderModelForHoKinhDoanh {
  final String id;
  final String hoKinhDoanhId;
  final NguoiDung userId;
  final diaChiList diaChi;
  final int TrangThai;
  final bool thanhToan;
  final int TongTien;
  final KhuyenMaiModel? khuyenmaiId;
  final int transactionId;
  final List<ChiTietHoaDon>? chiTietHoaDon;
  final String GhiChu;
  final DateTime expiresAt;
  final DateTime NgayTao;
  final String mrc_order_id;
  final int SoTienKhuyenMai;

  OrderModelForHoKinhDoanh({
    required this.id,
    required this.userId,
    required this.hoKinhDoanhId,
    required this.diaChi,
    required this.TrangThai,
    required this.thanhToan,
    required this.TongTien,
    required this.khuyenmaiId,
    required this.transactionId,
    required this.chiTietHoaDon,
    required this.GhiChu,
    required this.NgayTao,
    required this.expiresAt,
    required this.mrc_order_id,
    required this.SoTienKhuyenMai,
  });

  factory OrderModelForHoKinhDoanh.fromJson(Map<String, dynamic> json) {
    // Safely handle chiTietHoaDon list
    var chiTietHoaDonFromJson = json['chiTietHoaDon'] as List<dynamic>? ?? [];

    List<ChiTietHoaDon> listCart = chiTietHoaDonFromJson
        .whereType<Map<String, dynamic>>()
        .map((item) => ChiTietHoaDon.fromJson(item))
        .toList();

    // Safely handle diaChi
    diaChiList diaChi;
    if (json['diaChi'] != null && json['diaChi'] is Map<String, dynamic>) {
      diaChi = diaChiList.fromJson(json['diaChi']);
    } else {
      diaChi = diaChiList(); // Use default constructor if diaChi is null
    }

    // Safely handle userId
    NguoiDung userId;
    if (json['userId'] != null && json['userId'] is Map<String, dynamic>) {
      userId = NguoiDung.fromJson(json['userId']);
    } else {
      throw Exception("Missing or invalid 'userId' data in JSON");
    }

    // Return the object
    return OrderModelForHoKinhDoanh(
      id: json['_id'] ?? '',
      hoKinhDoanhId: json['hoKinhDoanhId'] ?? '',
      userId: userId,
      diaChi: diaChi,
      TongTien: json['TongTien'] ?? 0,
      TrangThai: json['TrangThai'] ?? 0,
      thanhToan: json['ThanhToan'] ?? false,
      chiTietHoaDon: listCart,
      GhiChu: json['GhiChu'] ?? '',
      transactionId: json['transactionId'] ?? 0,
      khuyenmaiId: json['khuyenmaiId'] != null
          ? KhuyenMaiModel.fromJson(json['khuyenmaiId'])
          : null,
      NgayTao: DateTime.tryParse(json['NgayTao'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
      mrc_order_id: json['mrc_order_id'] ?? '',
      SoTienKhuyenMai: json['SoTienKhuyenMai'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hoKinhDoanhId': hoKinhDoanhId,
      'userId': userId.toJson(),
      'diaChi': diaChi.toJson(),
      'TrangThai': TrangThai,
      'ThanhToan': thanhToan,
      'TongTien': TongTien,
      'khuyenmaiId': khuyenmaiId?.toJson(),
      'transactionId': transactionId,
      'chiTietHoaDon': chiTietHoaDon?.map((item) => item.toJson()).toList(),
      'GhiChu': GhiChu,
      'NgayTao': NgayTao.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'SoTienKhuyenMai': SoTienKhuyenMai,
    };
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, TongTien: $TongTien, TrangThai: $TrangThai, NgayTao: $NgayTao, mrc_order_id: $mrc_order_id)';
  }
}

class ChiTietHoaDon {
  final String id;
  final BienTheModel? bienThe;
  final int soLuong;
  final int donGia;

  ChiTietHoaDon({
    required this.id,
    required this.bienThe,
    required this.soLuong,
    required this.donGia,
  });

  factory ChiTietHoaDon.fromJson(Map<String, dynamic> json) {
    return ChiTietHoaDon(
      id: json['_id'] ?? '',
      bienThe: json['idBienThe'] != null
          ? BienTheModel.fromJSON(json['idBienThe'])
          : null,
      soLuong: json['soLuong'] as int? ?? 0,
      donGia: json['donGia'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBienThe': bienThe?.toJson(),
      'soLuong': soLuong,
      'donGia': donGia,
    };
  }
}

class BienTheModel {
  final ProductModel idSanPham;
  final String sku;
  final int gia;
  final int soLuong;
  final List<KetHopThuocTinh2> ketHopThuocTinh;

  BienTheModel({
    required this.idSanPham,
    required this.sku,
    required this.gia,
    required this.soLuong,
    required this.ketHopThuocTinh,
  });

  factory BienTheModel.fromJSON(Map<String, dynamic> json) {
    var ketHopThuocTinhFromJson =
        json['KetHopThuocTinh'] as List<dynamic>? ?? [];

    List<KetHopThuocTinh2> listKetHopThuocTinh = ketHopThuocTinhFromJson
        .map((item) => KetHopThuocTinh2.fromJson(item as Map<String, dynamic>))
        .toList();

    return BienTheModel(
      idSanPham: ProductModel.fromJSON(json['IDSanPham'] ?? {}),
      sku: json['sku'] ?? '',
      gia: json['gia'] ?? 0,
      soLuong: json['soLuong'] ?? 0,
      ketHopThuocTinh: listKetHopThuocTinh,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDSanPham': idSanPham.toJson(),
      'sku': sku,
      'gia': gia,
      'soLuong': soLuong,
      'KetHopThuocTinh': ketHopThuocTinh.map((item) => item.toJson()).toList(),
    };
  }
}

class KetHopThuocTinh2 {
  final GiaTriThuocTinh giaTriThuocTinh;
  final String id;

  KetHopThuocTinh2({
    required this.giaTriThuocTinh,
    required this.id,
  });

  factory KetHopThuocTinh2.fromJson(Map<String, dynamic> json) {
    return KetHopThuocTinh2(
      giaTriThuocTinh: GiaTriThuocTinh.fromJson(
          json['IDGiaTriThuocTinh'] as Map<String, dynamic>),
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GiaTriThuocTinh': giaTriThuocTinh.toJson(),
      'id': id,
    };
  }
}

class GiaTriThuocTinh {
  final String giaTri;
  final ThuocTinh2 thuocTinh;

  GiaTriThuocTinh({
    required this.giaTri,
    required this.thuocTinh,
  });

  factory GiaTriThuocTinh.fromJson(Map<String, dynamic> json) {
    return GiaTriThuocTinh(
      giaTri: json['GiaTri'] ?? '',
      thuocTinh: ThuocTinh2.fromJson(json['ThuocTinhID'] != null
          ? {
              'TenThuocTinh': json['ThuocTinhID'] // assuming this maps to the "TenThuocTinh"
            }
          : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GiaTri': giaTri,
      'ThuocTinh': thuocTinh.toJson(),
    };
  }
}

class ThuocTinh2 {
  final String tenThuocTinh;

  ThuocTinh2({
    required this.tenThuocTinh,
  });

  factory ThuocTinh2.fromJson(Map<String, dynamic> json) {
    return ThuocTinh2(
      tenThuocTinh: json['TenThuocTinh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TenThuocTinh': tenThuocTinh,
    };
  }
}
