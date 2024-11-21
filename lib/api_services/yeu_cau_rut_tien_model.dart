class WithdrawalRequest {
  final String id;
  final String userId;
  final String tenNganHang;
  final String soTaiKhoan;
  final double soTien;
  final String ghiChu;
  final bool isDeleted;
  final bool daXuLy;
  final bool xacThuc;
  final DateTime ngayYeuCau;
  final DateTime createdAt;
  final DateTime updatedAt;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.tenNganHang,
    required this.soTaiKhoan,
    required this.soTien,
    required this.ghiChu,
    required this.isDeleted,
    required this.daXuLy,
    required this.xacThuc,
    required this.ngayYeuCau,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a WithdrawalRequest from JSON
  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      tenNganHang: json['tenNganHang'] as String,
      soTaiKhoan: json['soTaiKhoan'] as String,
      soTien: (json['soTien'] as num).toDouble(),
      ghiChu: json['ghiChu'] as String,
      isDeleted: json['isDeleted'] as bool,
      daXuLy: json['daXuLy'] as bool,
      xacThuc: json['XacThuc'] as bool,
      ngayYeuCau: DateTime.parse(json['ngayYeuCau'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Method to convert a WithdrawalRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'tenNganHang': tenNganHang,
      'soTaiKhoan': soTaiKhoan,
      'soTien': soTien,
      'ghiChu': ghiChu,
      'isDeleted': isDeleted,
      'daXuLy': daXuLy,
      'XacThuc': xacThuc,
      'ngayYeuCau': ngayYeuCau.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
