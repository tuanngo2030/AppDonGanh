import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';

class OrderModel {
  final String id;
  final NguoiDung userId;
  final diaChiList diaChi;
  final int TongTien;
  final int TrangThai;
  final bool thanhToan;
  final List<ChiTietHoaDon> chiTietHoaDon;
  final String GhiChu;
  final DateTime NgayTao;

  OrderModel({
    required this.id,
    required this.userId,
    required this.diaChi,
    required this.TongTien,
    required this.TrangThai,
    required this.thanhToan,
    required this.chiTietHoaDon,
    required this.GhiChu,
    required this.NgayTao,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var chiTietHoaDonFromJson = json['chiTietHoaDon'] as List<dynamic>? ?? [];

    List<ChiTietHoaDon> listCart = chiTietHoaDonFromJson
        .map((item) => ChiTietHoaDon.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['_id'] ?? '',
      userId: NguoiDung.fromJson(json['userId'] as Map<String, dynamic>),
      diaChi: diaChiList.fromJson(json['diaChi'] as Map<String, dynamic>),
      TongTien: json['TongTien'] ?? 0,
      TrangThai: json['TrangThai'] ?? 4,
      thanhToan: json['ThanhToan'] ?? false,
      chiTietHoaDon: listCart,
      GhiChu: json['GhiChu'] ?? '',
      NgayTao: DateTime.tryParse(json['NgayTao'] ?? DateTime.now().toString()) ?? DateTime.now(),
    );
  }
}

class ChiTietHoaDon {
  final BienTheModel bienThe;
  final int soLuong;
  final int donGia;

  ChiTietHoaDon({
    required this.bienThe,
    required this.soLuong,
    required this.donGia,
  });

  factory ChiTietHoaDon.fromJson(Map<String, dynamic> json) {
    return ChiTietHoaDon(
      bienThe: BienTheModel.fromJSON(json['BienThe'] as Map<String, dynamic>),
      soLuong: json['soLuong'] ?? 0,
      donGia: json['donGia'] ?? 0,
    );
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
    var ketHopThuocTinhFromJson = json['KetHopThuocTinh'] as List<dynamic>? ?? [];

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
      giaTriThuocTinh: GiaTriThuocTinh.fromJson(json['GiaTriThuocTinh'] as Map<String, dynamic>),
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