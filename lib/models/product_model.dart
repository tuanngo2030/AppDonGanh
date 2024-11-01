class ProductModel {
   static const String defaultImageUrl = 'https://coffective.com/wp-content/uploads/2018/06/default-featured-image.png.jpg'; // Thay bằng URL hình mặc định của bạn

  final String id;
  final String idProduct;
  final String nameProduct;
  final String imageProduct;
  final int donGiaNhap;
  final int donGiaBan;
  final int soLuongNhap;
  final int soLuongHienTai;
  final int phanTramGiamGia;
  final DateTime ngayTao;
  final String tinhTrang;
  final String moTa;
  final String Unit;
  final List<danhSachThuocTinh> listThuocTinh;
  final String IDDanhMuc;
  final String IDDanhMucCon;
  final List<hinhBoSung> ImgBoSung;

  ProductModel(
      {
      required this.id,
      required this.idProduct,
      required this.nameProduct,
      required this.imageProduct,
      required this.donGiaNhap,
      required this.donGiaBan,
      required this.soLuongNhap,
      required this.soLuongHienTai,
      required this.phanTramGiamGia,
      required this.ngayTao,
      required this.tinhTrang,
      required this.moTa,
      required this.Unit,
      required this.listThuocTinh,
      required this.IDDanhMuc,
      required this.IDDanhMucCon,
      required this.ImgBoSung});

       // Hàm kiểm tra URL hợp lệ
  static bool isValidUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  

  factory ProductModel.fromJSON(Map<String, dynamic> data) {
    var danhsachThuocTinhFromJson = data['DanhSachThuocTinh'] as List<dynamic>;
    List<danhSachThuocTinh> listThuocTinh = danhsachThuocTinhFromJson
        .map((item) => danhSachThuocTinh.fromJSON(item))
        .toList();

    var ImgBoSungFromJson = data['HinhBoSung'] as List<dynamic>;
    List<hinhBoSung> ImgBoSung =
        ImgBoSungFromJson.map((item) => hinhBoSung.fromJSON(item)).toList();

         String imageProductUrl = data['HinhSanPham'] ?? '';
    if (!isValidUrl(imageProductUrl)) {
      imageProductUrl = defaultImageUrl;
    }

    return ProductModel(
      id: data['_id'],
      idProduct: data['IDSanPham'],
      nameProduct: data['TenSanPham'],
      imageProduct: data['HinhSanPham'],
      donGiaNhap: data['DonGiaNhap'],
      donGiaBan: data['DonGiaBan'],
      soLuongNhap: data['SoLuongNhap'],
      soLuongHienTai: data['SoLuongHienTai'],
      phanTramGiamGia: data['PhanTramGiamGia'],
      ngayTao: DateTime.parse(data['NgayTao']),
      tinhTrang: data['TinhTrang'],
      moTa: data['MoTa'],
      Unit: data['Unit'],
      listThuocTinh: listThuocTinh,
      IDDanhMuc: data['IDDanhMuc'],
      IDDanhMucCon: data['IDDanhMucCon'],
      ImgBoSung: ImgBoSung,
    );
  }

  
}

class danhSachThuocTinh {
  final String id;

  danhSachThuocTinh({required this.id});

  factory danhSachThuocTinh.fromJSON(Map<String, dynamic> data) {
    return danhSachThuocTinh(
      id: data['_id'],
    );
  }
}

class hinhBoSung {
  final String id;
  final String nameImg;
  final String url;

  hinhBoSung({required this.id, required this.nameImg ,required this.url});

  factory hinhBoSung.fromJSON(Map<String, dynamic> data) {
    return hinhBoSung(
      id: data['_id'],
      nameImg: data['TenAnh'],
      url: data['UrlAnh'],
    );
  }
}
