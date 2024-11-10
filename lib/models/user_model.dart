class NguoiDung {
  final String? id;
  final String? anhDaiDien;
  final String? tenNguoiDung;
  final String? soDienThoai;
  final String? gmail;
  final String? GioiTinh;
  final String? matKhau;
  final DateTime? ngayTao;
  final String? ngaySinh;
  final bool? hoKinhDoanh;
  final int? tinhTrang;
  final List<String>? phuongThucThanhToan;
  final String? role;
  final String? otp;
  final DateTime? otpExpiry;
  final bool? isVerified;
  final String? googleId;
  final String? facebookId;
  final String? IDYeuThich;
  final List<Permission>? permissions;

  NguoiDung({
    this.id,
    this.anhDaiDien,
    this.tenNguoiDung,
    this.soDienThoai,
    this.gmail,
    this.GioiTinh,
    this.matKhau,
    this.ngayTao,
    this.ngaySinh,
    this.hoKinhDoanh,
    this.tinhTrang,
    this.phuongThucThanhToan,
    this.role,
    this.otp,
    this.otpExpiry,
    this.isVerified,
    this.googleId,
    this.facebookId,
    this.IDYeuThich,
    this.permissions,
  });

  // Convert JSON to NguoiDung
  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      id: json['_id'] as String?,
      anhDaiDien: json['anhDaiDien'] as String?,
      tenNguoiDung: json['tenNguoiDung'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      gmail: json['gmail'] as String?,
      GioiTinh: json['GioiTinh'] as String?,
      matKhau: json['matKhau'] as String?,
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngaySinh: json['ngaySinh'] as String?,
      hoKinhDoanh: json['hoKinhDoanh'] as bool? ?? false,
      tinhTrang: json['tinhTrang'],
      phuongThucThanhToan: json['phuongThucThanhToan'] != null
          ? List<String>.from(json['phuongThucThanhToan'])
          : null,
      role: json['role'] as String? ?? 'user',
      otp: json['otp'] as String?,
      otpExpiry:
          json['otpExpiry'] != null ? DateTime.parse(json['otpExpiry']) : null,
      isVerified:
          json['isVerified'] != null ? json['isVerified'] as bool : false,
      googleId: json['googleId'] as String?,
      facebookId: json['facebookId'] as String?,
      IDYeuThich: json['IDYeuThich'] as String?,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
              .map((permissionJson) => Permission.fromJson(permissionJson))
              .toList()
          : [],
    );
  }

  // Convert NguoiDung to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'anhDaiDien': anhDaiDien,
      'tenNguoiDung': tenNguoiDung,
      'soDienThoai': soDienThoai,
      'gmail': gmail,
      'GioiTinh': GioiTinh,
      'matKhau': matKhau,
      'ngayTao': ngayTao?.toIso8601String(),
      'ngaySinh': ngaySinh,
      'hoKinhDoanh': hoKinhDoanh,
      'tinhTrang': tinhTrang,
      'phuongThucThanhToan': phuongThucThanhToan,
      'role': role,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'isVerified': isVerified,
      'googleId': googleId,
      'facebookId': facebookId,
      'IDYeuThich': IDYeuThich
    };
  }
}

class Permission {
  final String? entity;
  final List<String>? actions;
  final String? id;

  Permission({
    this.entity,
    this.actions,
    this.id,
  });

  // Convert JSON to Permission
  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      entity: json['entity'] as String?,
      actions:
          json['actions'] != null ? List<String>.from(json['actions']) : null,
      id: json['_id'] as String?,
    );
  }

  // Convert Permission to JSON
  Map<String, dynamic> toJson() {
    return {
      'entity': entity,
      'actions': actions,
      '_id': id,
    };
  }
}
