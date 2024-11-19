class NotificationModel {
  final String id;
  final String tieude;
  final String noidung;
  final DateTime? ngayTao;
  final bool daDoc;

  NotificationModel({
    required this.id,
    required this.tieude,
    required this.noidung,
    required this.ngayTao,
    required this.daDoc,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      tieude: json['tieude'] ?? '',
      noidung: json['noidung'] ?? '',
      ngayTao: json['ngayTao'] != null
          ? DateTime.parse(json['ngayTao'])
          : null,
      daDoc: json['daDoc'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tieude': tieude,
      'noidung': noidung,
      'ngayTao': ngayTao?.toIso8601String(),
      'daDoc': daDoc,
    };
  }

  // Hàm sao chép đối tượng với các thuộc tính được sửa đổi
  NotificationModel copyWith({
    String? id,
    String? tieude,
    String? noidung,
    DateTime? ngayTao,
    bool? daDoc,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      tieude: tieude ?? this.tieude,
      noidung: noidung ?? this.noidung,
      ngayTao: ngayTao ?? this.ngayTao,
      daDoc: daDoc ?? this.daDoc,
    );
  }
}
