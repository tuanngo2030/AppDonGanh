class CategoryModel {
  final String id;
  final String ten_danh_muc;
  final String image;
  final List<childCategories> danh_muc_con;

  CategoryModel({
      required this.id,
      required this.ten_danh_muc,
      required this.image,
      required this.danh_muc_con
    });

  factory CategoryModel.fromJSON(Map<String, dynamic> data) {
      // Chuyển đổi danh_muc_con từ List<dynamic> thành List<childCategories>
    var danhMucConFromJson = data['DanhMucCon'] as List<dynamic>;
    List<childCategories> danhMucConList = danhMucConFromJson.map((item) => childCategories.fromJSON(item)).toList();

    return CategoryModel(
        id: data['IDDanhMuc'],
        ten_danh_muc: data['TenDanhMuc'],
        image: data['AnhDanhMuc'],
        danh_muc_con: danhMucConList);
  }
}


class childCategories {
  final String id;
  final String ten_danh_muc_con;
  final String mo_ta;

  childCategories({
    required this.id, 
    required this.ten_danh_muc_con, 
    required this.mo_ta
  });

  factory childCategories.fromJSON(Map<String, dynamic> data) {
     return childCategories(
        id: data['IDDanhMucCon'],
        ten_danh_muc_con: data['TenDanhMucCon'],
        mo_ta: data['MieuTa'],
      );
  }
  }

