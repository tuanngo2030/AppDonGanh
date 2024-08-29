class DiaChi{
  final String tinhThanhPho;
  final String quanHuyen;
  final String phuongXa;
  final String duongThon;

  DiaChi({
    required this.tinhThanhPho,
    required this.quanHuyen,
    required this.phuongXa,
    required this.duongThon,
  });

  factory DiaChi.fromJson(Map<String, dynamic> json) {
    return DiaChi(
      tinhThanhPho: json['tinhThanhPho'] ?? 'Chưa cập nhật',
      quanHuyen: json['quanHuyen'] ?? 'Chưa cập nhật',
      phuongXa: json['phuongXa'] ?? 'Chưa cập nhật',
      duongThon: json['duongThon'] ?? 'Chưa cập nhật',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tinhThanhPho': tinhThanhPho,
      'quanHuyen': quanHuyen,
      'phuongXa': phuongXa,
      'duongThon': duongThon,
    };
  }
}
