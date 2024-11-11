import 'package:don_ganh_app/models/product_model.dart';

class Message {
  final String id;
  final String text;
  final String? imageUrl; // Optional field for image URL
  final String? videoUrl; // Optional field for video URL
  final ProductModel? IDSanPham; // Optional field for
  final bool seen;
  final String msgByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.text,
    this.imageUrl, // Initialize as optional
    this.videoUrl, // Initialize as optional
    this.IDSanPham, // Initialize as optional
    required this.seen,
    required this.msgByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tạo phương thức từ JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      text: json['text'],
      imageUrl: json['imageUrl'], // Parse image URL if exists
      videoUrl: json['videoUrl'], // Parse video URL if exists
        IDSanPham: json['IDSanPham'] != null ? ProductModel.fromJSON(json['IDSanPham']) : null,
      seen: json['seen'],
      msgByUserId: json['msgByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Tạo phương thức chuyển đổi ngược lại thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'imageUrl': imageUrl, // Include image URL in JSON
      'videoUrl': videoUrl, // Include video URL in JSON
       'IDSanPham': IDSanPham?.toJson(),
      'seen': seen,
      'msgByUserId': msgByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
