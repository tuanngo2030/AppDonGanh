class CategoryModel {
  final int id;
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
    // var danhMucConFromJson = data['danh_muc_con'] as List<dynamic>;
    // List<childCategories> danhMucConList = danhMucConFromJson.map((item) => childCategories.fromJSON(item)).toList();

    return CategoryModel(
        id: data['id'],
        ten_danh_muc: data['ten_danh_muc'],
        image: data['url'],
        danh_muc_con: data['danh_muc_con']);
  }
}


class childCategories {
  final int id;
  final String ten_danh_muc_con;
  final String mo_ta;

  childCategories({
    required this.id, 
    required this.ten_danh_muc_con, 
    required this.mo_ta
  });
}
