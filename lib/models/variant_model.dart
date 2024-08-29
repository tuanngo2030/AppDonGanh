class VariantModel {
  final String id;
  final String idProduct;
  final String sku;
  final int soLuong;
  final List<KetHopThuocTinh> ketHopThuocTinh;

  VariantModel({
    required this.id,
    required this.idProduct,
    required this.sku,
    required this.soLuong,
    required this.ketHopThuocTinh,
  });

  factory VariantModel.fromJSON(Map<String, dynamic> data) {
    var ketHopThuocTinhFromJson = data['KetHopThuocTinh'] as List<dynamic>;
    List<KetHopThuocTinh> ketHopThuocTinh = ketHopThuocTinhFromJson
        .map((item) => KetHopThuocTinh.fromJSON(item as Map<String, dynamic>))
        .toList();

    return VariantModel(
      id: data['_id'],
      idProduct: data['IDSanPham'],
      sku: data['sku'],
      soLuong: data['soLuong'],
      ketHopThuocTinh: ketHopThuocTinh,
    );
  }
}

class KetHopThuocTinh {
  final String id;
  final GiaTriThuocTinh giaTriThuocTinh;

  KetHopThuocTinh({
    required this.id,
    required this.giaTriThuocTinh,
  });

  factory KetHopThuocTinh.fromJSON(Map<String, dynamic> data) {
    return KetHopThuocTinh(
      id: data['_id'],
      giaTriThuocTinh: GiaTriThuocTinh.fromJSON(data['IDGiaTriThuocTinh'] as Map<String, dynamic>),
    );
  }
}

class GiaTriThuocTinh{
  final String id;
  final String IDGiaTriThuocTinh;
  final String ThuocTinhID;
  final String GiaTri;

  GiaTriThuocTinh({
    required this.id, 
    required this.IDGiaTriThuocTinh, 
    required this.ThuocTinhID, 
    required this.GiaTri
  });

  factory GiaTriThuocTinh.fromJSON(Map<String, dynamic> data){
    return GiaTriThuocTinh(
      id: data['_id'], 
      IDGiaTriThuocTinh: data['IDGiaTriThuocTinh'], 
      ThuocTinhID: data['ThuocTinhID'], 
      GiaTri: data['GiaTri']
    );
  }

}
