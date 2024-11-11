import 'package:don_ganh_app/api_services/favorite_api_service.dart';
import 'package:don_ganh_app/models/favorite_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<ProductModel> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // Function to toggle the favorite status of a product
 Future<void> _toggleFavorite(BuildContext context, String productId) async {
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
    // Kiểm tra nếu sản phẩm đã được yêu thích
    ProductModel product = favorites.firstWhere((item) => item.id == productId);
    bool isCurrentlyFavorite = product.isFavorited;

    // Nếu sản phẩm đang được yêu thích, xóa khỏi danh sách yêu thích
    if (!isCurrentlyFavorite) {
       favoriteService.addToFavorites(userId, productId);

      // Cập nhật lại UI: Xóa sản phẩm khỏi danh sách yêu thích
      setState(() {
        favorites.removeWhere((item) => item.id == productId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa sản phẩm khỏi danh sách yêu thích')),
      );
    } else {
      // Nếu sản phẩm chưa được yêu thích, thêm vào danh sách yêu thích
       favoriteService.addToFavorites(userId, productId);

      // Cập nhật lại trạng thái isFavorited của sản phẩm trong danh sách favorites
      setState(() {
        product.isFavorited = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}

  Future<void> _fetchFavorites() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId == null) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User ID not found. Please log in again.')),
    );
    return;
  }

  try {
    final favoriteList = await FavoriteApiService().getFavorites(userId);
    if (mounted) {
      setState(() {
        favorites = favoriteList;
        isLoading = false;
      });
    }
  } catch (error) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading favorites: $error')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
        ),
        title: const Text(
          'Yêu thích',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.isEmpty
                ? const Center(child: Text('Không có sản phẩm yêu thích nào'))
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 27, vertical: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final product = favorites[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailProductScreen(
                                    product: product,
                                    isfavorited: true),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Flexible(
                                child: Stack(
                                  children: [
                                    // Product Image
                                    SizedBox(
                                      height: 150,
                                      width: 200,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          product.imageProduct,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, exception, stackTrace) {
                                            return Image.asset(
                                              'lib/assets/avt2.jpg',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Discount Badge
                                    Positioned(
                                      top: 15,
                                      child: Container(
                                        width: 50,
                                        height: 25,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color:
                                              Color.fromRGBO(142, 198, 65, 1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "- ${product.phanTramGiamGia}%",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
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
                                          _toggleFavorite(
                                              context,
                                              product.id); // Toggle the favorite status
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                            color: product.isFavorited
                                                ? const Color.fromRGBO(
                                                    241, 247, 234, 1)
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Center(
                                            child: Icon(
                                                product.isFavorited
                                                    ? Icons
                                                        .favorite_border_outlined
                                                    : Icons.favorite,
                                                color: product.isFavorited
                                                    ? const Color.fromRGBO(
                                                        142, 198, 65, 1)
                                                    : Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Product Name, Rating, and Price
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.nameProduct,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w900,
                                          color: Color.fromRGBO(41, 87, 35, 1),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber),
                                        Text("5"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(product.donGiaBan)} đ/kg',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 'Add to Cart' Button
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    print('Add to cart');
                                  },
                                  child: Container(
                                    height: 35,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: const Border.fromBorderSide(
                                            BorderSide(
                                                color: Colors.black,
                                                width: 1.5)),
                                        color:
                                            const Color.fromRGBO(41, 87, 35, 1),
                                        borderRadius:
                                            BorderRadius.circular(20)),
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
                    ),
                  ),
      ),
    );
  }
}
