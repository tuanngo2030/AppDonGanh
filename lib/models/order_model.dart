import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final diaChiList diaChi;
  final int TrangThai;
  final bool thanhToan;
  final int TongTien;
  final String khuyenmaiId;
  final int transactionId;
  final List<ChiTietHoaDon>? chiTietHoaDon;
  final String GhiChu;
  // final String YeuCauNhanHang;
  final String payment_url;
  final String redirect_url;
  final int order_id;
  final DateTime expiresAt;
  final DateTime NgayTao;
  final String mrc_order_id;

  OrderModel({
    required this.id,
    required this.userId,
    // required this.orderId,
    required this.diaChi,
    required this.TrangThai,
    required this.thanhToan,
    required this.TongTien,
    required this.khuyenmaiId,
    required this.transactionId,
    required this.chiTietHoaDon,
    required this.GhiChu,
    // required this.YeuCauNhanHang,
    required this.NgayTao,
    required this.payment_url,
    required this.redirect_url,
    required this.order_id,
    required this.expiresAt,
    required this.mrc_order_id,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Safely handle chiTietHoaDon list
    var chiTietHoaDonFromJson = json['chiTietHoaDon'] as List<dynamic>? ?? [];

    List<ChiTietHoaDon> listCart = chiTietHoaDonFromJson
        .map((item) => item is Map<String, dynamic>
            ? ChiTietHoaDon.fromJson(item)
            : ChiTietHoaDon.fromJson({}))
        .toList();

    // Safely handle diaChi
    diaChiList diaChi;
    if (json['diaChi'] is Map<String, dynamic>) {
      diaChi = diaChiList.fromJson(json['diaChi']);
    } else {
      diaChi =
          diaChiList(); // Provide a default constructor or handle accordingly
    }

    // Ensure proper parsing of nested structures
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['userId'] is String
          ? json['userId']
          : (json['userId'] != null
              ? json['userId']['_id']
              : ''), // If nested, access id
      diaChi: diaChi,
      TongTien: json['TongTien'] ?? 0,
      TrangThai: json['TrangThai'] ?? 0,
      thanhToan: json['ThanhToan'] ?? false,
      chiTietHoaDon: listCart,
      GhiChu: json['GhiChu'] ?? '',
      transactionId: json['transactionId'] ?? 0,
      khuyenmaiId: json['khuyenmaiId'] ?? '',
      // YeuCauNhanHang: json['YeuCauNhanHang'] ?? '',
      NgayTao: DateTime.tryParse(json['NgayTao'] ?? '') ?? DateTime.now(),
      payment_url: json['payment_url'] ?? '',
      redirect_url: json['redirect_url'] ?? '',
      order_id: json['order_id'] ?? 0,
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
      mrc_order_id: json['mrc_order_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'diaChi': diaChi.toJson(),
      'TrangThai': TrangThai,
      'ThanhToan': thanhToan,
      'TongTien': TongTien,
      'khuyenmaiId': khuyenmaiId,
      'transactionId': transactionId,
      'chiTietHoaDon': chiTietHoaDon?.map((item) => item.toJson()).toList(),
      'GhiChu': GhiChu,
      // 'YeuCauNhanHang': YeuCauNhanHang,
      'NgayTao': NgayTao.toIso8601String(),
      'payment_url': payment_url,
      'redirect_url': redirect_url,
      'order_id': order_id,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

class ChiTietHoaDon {
  final String id;
  final String bienThe;
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
      id : json['_id'] ?? '',
      bienThe: json['idBienThe'] is String ? json['idBienThe'] : '',
      soLuong: json['soLuong'] as int? ?? 0,
      donGia: json['donGia'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBienThe': bienThe,
      'soLuong': soLuong,
      'donGia': donGia,
    };
  }
}

class BienTheModel {
  final String idSanPham;
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
      idSanPham: json['IDSanPham'] ?? '',
      sku: json['sku'] ?? '',
      gia: json['gia'] ?? 0,
      soLuong: json['soLuong'] ?? 0,
      ketHopThuocTinh: listKetHopThuocTinh,
    );
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
          json['GiaTriThuocTinh'] as Map<String, dynamic>),
      id: json['_id'] ?? '',
    );
  }
}

class GiaTriThuocTinh {
  final ThuocTinh2 thuocTinh;
  final String giaTri;

  GiaTriThuocTinh({
    required this.thuocTinh,
    required this.giaTri,
  });

  factory GiaTriThuocTinh.fromJson(Map<String, dynamic> json) {
    return GiaTriThuocTinh(
      thuocTinh: ThuocTinh2.fromJson(json['ThuocTinh'] as Map<String, dynamic>),
      giaTri: json['GiaTri'] ?? '',
    );
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
}
