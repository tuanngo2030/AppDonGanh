class diaChiList {
  final String? id;
  final String? name;
  final String? soDienThoai;
  final String? tinhThanhPho;
  final String? quanHuyen;
  final String? phuongXa;
  final String? duongThon;
  final bool isDeleted;

  diaChiList({
    this.id,
    this.name,
    this.soDienThoai,
    this.tinhThanhPho,
    this.quanHuyen,
    this.phuongXa,
    this.duongThon,
    this.isDeleted = false, // Gán mặc định cho isDeleted
  });

  // Convert JSON to DiaChi
  factory diaChiList.fromJson(Map<String, dynamic> json) {
    return diaChiList(
      id: json['_id'] as String?,
      name: json['Name'] as String?, // Chỉnh sửa tên trường
      soDienThoai: json['SoDienThoai'] as String?, // Chỉnh sửa tên trường
      tinhThanhPho: json['tinhThanhPho'] as String?,
      quanHuyen: json['quanHuyen'] as String?,
      phuongXa: json['phuongXa'] as String?,
      duongThon: json['duongThon'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  // Convert DiaChi to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Name': name, // Chỉnh sửa tên trường
      'SoDienThoai': soDienThoai, // Chỉnh sửa tên trường
      'tinhThanhPho': tinhThanhPho,
      'quanHuyen': quanHuyen,
      'phuongXa': phuongXa,
      'duongThon': duongThon,
      'isDeleted': isDeleted,
    };
  }
}
