import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/search_api_service.dart';
import 'package:don_ganh_app/models/product_model.dart'; // Import your ProductModel
import 'package:don_ganh_app/screen/detail_product_screen.dart'; // Import your DetailProductScreen

class SearchResultsScreen extends StatefulWidget {
  final String searchTerm;
  const SearchResultsScreen({super.key, required this.searchTerm});

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  Future<List<dynamic>>? sanphamsFuture;

  @override
  void initState() {
    super.initState();
    sanphamsFuture = searchSanPham(widget.searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kết quả tìm kiếm cho: ${widget.searchTerm}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<dynamic>>(
          future: sanphamsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không tìm thấy dữ liệu'));
            }

            List<dynamic> activeProducts = snapshot.data!
                .where((product) => product['TinhTrang'] != 'Đã xóa')
                .toList();

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: activeProducts.length,
              itemBuilder: (context, index) {
                final sanpham = activeProducts[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to detail screen with product info
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailProductScreen(
                          product: ProductModel.fromJSON(
                              sanpham), // Assuming you have a ProductModel that can be created from JSON
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Flexible(
                        child: Stack(
                          children: [
                            // Product Image
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  sanpham['HinhSanPham'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Image.asset(
                                      'lib/assets/avt2.jpg', // Ensure this path is correct
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )),
                            // Discount Badge
                            if (sanpham['PhanTramGiamGia'] != null)
                              Positioned(
                                top: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(142, 198, 65, 1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "- ${sanpham['PhanTramGiamGia']}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            // Favorite Icon
                            Positioned(
                              top: 10,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  // Handle favorite functionality
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(241, 247, 234, 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.favorite_border_outlined,
                                      color: Color.fromRGBO(142, 198, 65, 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sanpham['TenSanPham'] ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromRGBO(41, 87, 35, 1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            // Rating
                            const Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                Text("5"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${sanpham['DonGiaBan']} đ/kg',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      //Button add to cart
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            print('add to cart');
                          },
                          child: Container(
                            height: 35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: const Border.fromBorderSide(
                                BorderSide(color: Colors.black, width: 1.5),
                              ),
                              color: const Color.fromRGBO(41, 87, 35, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    width: 60,
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: double.infinity,
                                  width: 1,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                ),
                                const Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: SizedBox(
                                      width: 100,
                                      child: Text(
                                        'Mua Ngay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
