import 'package:flutter/material.dart';
import 'package:don_ganh_app/api_services/search_api_service.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:don_ganh_app/api_services/favorite_api_service.dart';

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
    _initializeSearch();
  }

  Future<void> _initializeSearch() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    const yeuthichId = '67299b5b3318cd90d77a43b6';
    sanphamsFuture = searchSanPham(widget.searchTerm, userId: userId, yeuthichId: yeuthichId);
    setState(() {});
  }

  // Function to handle the favorite toggle with API integration
  Future<void> _toggleFavorite(BuildContext context, String productId, bool isFavorited) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in.')),
      );
      return;
    }

    final favoriteService = FavoriteApiService();

    try {
      // Call the API to add or remove from favorites
      if (isFavorited) {
         favoriteService.addToFavorites(userId, productId);
      
      } else {
         favoriteService.addToFavorites(userId, productId);
      }

      // Update the UI after toggling the favorite
      setState(() {
        // Update the favorite status of the product inside the FutureBuilder data
        sanphamsFuture = sanphamsFuture!.then((products) {
          return products.map((product) {
            if (product['_id'] == productId) {
              product['isFavorited'] = !isFavorited;
            }
            return product;
          }).toList();
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isFavorited ? 'Removed from favorites' : 'Added to favorites')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
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
                bool isFavorited = sanpham['isFavorited'] ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailProductScreen(
                          product: ProductModel.fromJSON(sanpham), 
                          isfavorited: isFavorited,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Flexible(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                sanpham['HinhSanPham'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'lib/assets/avt2.jpg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            if (sanpham['PhanTramGiamGia'] != null)
                              Positioned(
                                top: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            Positioned(
                              top: 10,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  _toggleFavorite(context, sanpham['_id'] ?? '', isFavorited);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isFavorited ? Colors.red : const Color.fromRGBO(241, 247, 234, 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      isFavorited ? Icons.favorite : Icons.favorite_border_outlined,
                                      color: isFavorited ? Colors.white : const Color.fromRGBO(142, 198, 65, 1),
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
                                  color: Colors.black,
                                ),
                                const Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      'Mua Ngay',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
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
