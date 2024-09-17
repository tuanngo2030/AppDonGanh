import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/user_model.dart';

class OrderModel {
  final String id;
  final NguoiDung userId;
  final DiaChi diaChi;
  final String TongTien;
  final String TrangThai;
  final bool thanhToan;
  final List<ChiTietGioHang> chiTietGioHang;
  final String GhiChu;
  final DateTime NgayTao;

  OrderModel(
      {required this.id,
      required this.userId,
      required this.diaChi,
      required this.TongTien,
      required this.TrangThai,
      required this.thanhToan,
      required this.chiTietGioHang,
      required this.GhiChu,
      required this.NgayTao});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var chiTietGioHangFromJson = json['chiTietGioHang'] as List<dynamic>;
    List<ChiTietGioHang> listCart = chiTietGioHangFromJson
        .map((item) => ChiTietGioHang.fromJSON(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
        id: json['_id'],
        userId: NguoiDung.fromJson(json['userId'] as Map<String, dynamic>),
        diaChi: DiaChi.fromJson(json['diaChi'] as Map<String, dynamic>),
        TongTien: json['TongTien'],
        TrangThai: json['TrangThai'],
        thanhToan: json['ThanhToan'],
        chiTietGioHang: listCart,
        GhiChu: json['GhiChu'],
        NgayTao: DateTime.parse(json['NgayTao']));
  }
}
