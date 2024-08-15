class BannerModel {
  final String id;
  final String imageUrl;

  BannerModel({
    required this.id, 
    required this.imageUrl
    });

  factory BannerModel.fromJSON(Map<String, dynamic> data) {
    return BannerModel(id : data['_id'], imageUrl : data['hinhAnh']);
  }
}
