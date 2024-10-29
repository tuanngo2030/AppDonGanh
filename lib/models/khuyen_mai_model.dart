class KhuyenMaiModel {
  String id;
  String tenKhuyenMai;
  String moTa;
  int giaTriKhuyenMai;
  int tongSoLuongDuocTao;
  int gioiHanGiaTriDuocApDung;
  DateTime ngayBatDau;
  DateTime ngayKetThuc;
  int soLuongHienTai;
  String idLoaiKhuyenMai;
  String? idDanhMucCon;
  int trangThai;
  bool isDeleted;
  bool isEligible;
  int giaTriGiam;

  KhuyenMaiModel({
    required this.id,
    required this.tenKhuyenMai,
    required this.moTa,
    required this.giaTriKhuyenMai,
    required this.tongSoLuongDuocTao,
    required this.gioiHanGiaTriDuocApDung,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.soLuongHienTai,
    required this.idLoaiKhuyenMai,
    this.idDanhMucCon,
    required this.trangThai,
    required this.isDeleted,
    required this.isEligible,
    required this.giaTriGiam,
  });

  // Factory constructor for creating an instance from JSON
  factory KhuyenMaiModel.fromJson(Map<String, dynamic> json) {
    return KhuyenMaiModel(
      id: json['_id'],
      tenKhuyenMai: json['TenKhuyenMai'],
      moTa: json['MoTa'],
      giaTriKhuyenMai: json['GiaTriKhuyenMai'],
      tongSoLuongDuocTao: json['TongSoLuongDuocTao'],
      gioiHanGiaTriDuocApDung: json['GioiHanGiaTriDuocApDung'],
      ngayBatDau: DateTime.parse(json['NgayBatDau']),
      ngayKetThuc: DateTime.parse(json['NgayKetThuc']),
      soLuongHienTai: json['SoLuongHienTai'],
      idLoaiKhuyenMai: json['IDLoaiKhuyenMai'],
      idDanhMucCon: json['IDDanhMucCon'],
      trangThai: json['TrangThai'],
      isDeleted: json['isDeleted'],
      isEligible: json['isEligible'],
      giaTriGiam: json['giaTriGiam'],
    );
  }

  // Method for converting an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'TenKhuyenMai': tenKhuyenMai,
      'MoTa': moTa,
      'GiaTriKhuyenMai': giaTriKhuyenMai,
      'TongSoLuongDuocTao': tongSoLuongDuocTao,
      'GioiHanGiaTriDuocApDung': gioiHanGiaTriDuocApDung,
      'NgayBatDau': ngayBatDau.toIso8601String(),
      'NgayKetThuc': ngayKetThuc.toIso8601String(),
      'SoLuongHienTai': soLuongHienTai,
      'IDLoaiKhuyenMai': idLoaiKhuyenMai,
      'IDDanhMucCon': idDanhMucCon,
      'TrangThai': trangThai,
      'isDeleted': isDeleted,
      'isEligible': isEligible,
      'giaTriGiam': giaTriGiam,
    };
  }
}
