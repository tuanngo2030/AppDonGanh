import 'package:don_ganh_app/models/user_model.dart';

class BlogModel {
  final String id;
  final NguoiDung userId;
  final List<String> image;
  final String tieude;
  final String noidung;
  final List<String> likes;
  final List<PhanHoi> binhluan;
  final List<String> tags;
  final bool trangthai;
  final bool isUpdate;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isLiked;

  BlogModel({
    required this.id,
    required this.userId,
    required this.image,
    required this.tieude,
    required this.noidung,
    required this.likes,
    required this.binhluan,
    required this.tags,
    required this.trangthai,
    required this.isUpdate,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    var binhluanList = json['binhluan'] as List? ?? [];
    List<PhanHoi> binhluanItems = binhluanList.map((i) => PhanHoi.fromJson(i)).toList();

    return BlogModel(
      id: json['_id'] ?? '',
      userId: NguoiDung.fromJson(json['userId']),  
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      tieude: json['tieude'] ?? '',
      noidung: json['noidung'] ?? '',
      likes: json['likes'] != null ? List<String>.from(json['likes']) : [],
      binhluan: binhluanItems,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      trangthai: json['trangthai'] ?? false,
      isUpdate: json['isUpdate'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId.toJson(),
      'image': image,
      'tieude': tieude,
      'noidung': noidung,
      'likes': likes,
      'binhluan': binhluan.map((item) => item.toJson()).toList(),
      'tags': tags,
      'trangthai': trangthai,
      'isUpdate': isUpdate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLiked': isLiked,
    };
  }
}

class PhanHoi {
  final String id;
  final NguoiDung userId;
  final String binhLuan;
  final DateTime ngayTao;

  PhanHoi({
    required this.id,
    required this.userId,
    required this.binhLuan,
    required this.ngayTao,
  });

  factory PhanHoi.fromJson(Map<String, dynamic> json) {
    return PhanHoi(
      id: json['_id'] ?? '',
     userId: NguoiDung.fromJson(json['userId']),
      // userId: json['userId'],
      binhLuan: json['BinhLuan'] ?? '',
      ngayTao: json['NgayTao'] != null ? DateTime.parse(json['NgayTao']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId.toJson(),
      'BinhLuan': binhLuan,
      'NgayTao': ngayTao.toIso8601String(),
    };
  }
}
