class BannerModel {
  final int id;
  final String imageUrl;

  BannerModel({
    required this.id, 
    required this.imageUrl
    });

  factory BannerModel.fromJSON(Map<String, dynamic> data) {
    return BannerModel(id : data['id'],imageUrl: data['url']);
  }
}
