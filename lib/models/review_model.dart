import 'dart:convert';

import 'package:don_ganh_app/models/user_model.dart';

class PhanHoi {
  NguoiDung userId;
  String binhLuan;
  DateTime ngayTao;

  PhanHoi({
    required this.userId,
    required this.binhLuan,
    required this.ngayTao,
  });

  factory PhanHoi.fromJson(Map<String, dynamic> json) {
    return PhanHoi(
      userId: NguoiDung.fromJson(json['userId']),
      binhLuan: json['BinhLuan'],
      ngayTao: DateTime.parse(json['NgayTao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId.toJson(),
      'BinhLuan': binhLuan,
      'NgayTao': ngayTao.toIso8601String(),
    };
  }
}

class DanhGia {
  String id;
  NguoiDung userId;
  String sanphamId;
  List<String> HinhAnh; 
  int xepHang;
  String binhLuan;
  List<PhanHoi> phanHoi;
  DateTime ngayTao;
  List<dynamic> likes;
  bool isLiked;

  DanhGia({
    required this.id,
    required this.userId,
    required this.sanphamId,
    required this.HinhAnh, // Sửa ở đây
    required this.xepHang,
    required this.binhLuan,
    required this.phanHoi,
    required this.likes,
    required this.isLiked,
    DateTime? ngayTao,
  }) : ngayTao = ngayTao ?? DateTime.now();

  factory DanhGia.fromJson(Map<String, dynamic> json) {
    var phanHoiList = json['PhanHoi'] as List? ?? [];
    List<PhanHoi> phanHoiItems = phanHoiList.map((i) => PhanHoi.fromJson(i)).toList();

    // Lấy danh sách hình ảnh từ JSON
    var hinhAnhList = json['HinhAnh'] as List<dynamic> ?? [];
    List<String> hinhAnhItems = hinhAnhList.map((i) => i.toString()).toList(); 

    return DanhGia(
      id: json['_id'],
      userId: NguoiDung.fromJson(json['userId']),
      sanphamId: json['sanphamId'],
      HinhAnh: hinhAnhItems, 
      xepHang: json['XepHang'] ?? 0, // Thay đổi để đảm bảo là kiểu int
      binhLuan: json['BinhLuan'],
      phanHoi: phanHoiItems,
      ngayTao: DateTime.parse(json['NgayTao']),
      likes: json['likes'] ?? [],
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sanphamId': sanphamId,
      'HinhAnh': HinhAnh, 
      'XepHang': xepHang,
      'BinhLuan': binhLuan,
      'PhanHoi': phanHoi.map((i) => i.toJson()).toList(),
      'NgayTao': ngayTao.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
    };
  }
}

