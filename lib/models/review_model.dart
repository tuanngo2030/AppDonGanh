import 'dart:convert';

import 'package:don_ganh_app/models/user_model.dart';

class PhanHoi {
  String userId;
  String binhLuan;
  DateTime ngayTao;

  PhanHoi({
    required this.userId,
    required this.binhLuan,
    required this.ngayTao,
  });

  factory PhanHoi.fromJson(Map<String, dynamic> json) {
    return PhanHoi(
      userId: json['userId'],
      binhLuan: json['BinhLuan'],
      ngayTao: DateTime.parse(json['NgayTao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'BinhLuan': binhLuan,
      'NgayTao': ngayTao.toIso8601String(),
    };
  }
}

class DanhGia {
  String id;
  NguoiDung userId;
  String sanphamId;
  String hinhAnh;
  int xepHang;
  String binhLuan;
  List<PhanHoi> phanHoi;
  DateTime ngayTao;
   List<dynamic> likes; // Add likes based on JSON
  bool isLiked;

  DanhGia({
    required this.id,
    required this.userId,
    required this.sanphamId,
    required this.hinhAnh,
    required this.xepHang,
    required this.binhLuan,
    required this.phanHoi,
     required this.likes,
    required this.isLiked,
    
    DateTime? ngayTao,
  }) : ngayTao = ngayTao ?? DateTime.now();

  factory DanhGia.fromJson(Map<String, dynamic> json) {
    var phanHoiList = json['PhanHoi'] as List;
    List<PhanHoi> phanHoiItems = phanHoiList.map((i) => PhanHoi.fromJson(i)).toList();

    return DanhGia(
      id: json['_id'],
      userId: NguoiDung.fromJson(json['userId']),
      sanphamId: json['sanphamId'],
      hinhAnh: json['HinhAnh'] ?? '',
      xepHang: json['XepHang'] ?? '',
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
      'HinhAnh': hinhAnh,
      'XepHang': xepHang,
      'BinhLuan': binhLuan,
      'PhanHoi': phanHoi.map((i) => i.toJson()).toList(),
      'NgayTao': ngayTao.toIso8601String(),
       'likes': likes, 
      'isLiked': isLiked, 
    };
  }
}
