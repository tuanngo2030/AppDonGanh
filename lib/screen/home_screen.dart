// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/api_services/favorite_api_service.dart';
import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:don_ganh_app/widget/badge_widget.dart';
import 'package:don_ganh_app/widget/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:don_ganh_app/api_services/category_api_service.dart';
import 'package:don_ganh_app/models/categories_model.dart';
import 'package:don_ganh_app/api_services/banner_api_service.dart';
import 'package:don_ganh_app/models/banner_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<BannerModel>> bannerImage;
  // late Future<List<ProductModel>> productsModel;
  int _currentIndex = 0;
  int currentPage = 1;
  int totalPages = 1;
  List<ProductModel> productList = [];
  bool isLoading = true;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  int productsPerPage = 10;
  String? userId;
   String? IDYeuThich;
  Map<String, bool> favorites = {};
  List<String> favoriteIds = [];
  @override
  void initState() {
    super.initState();
    bannerImage = BannerApiService().fetchBanner();
    // productsModel = ProductApiService().getListProduct();
    // fetchPaginatedProducts();
    fetchProducts(currentPage);
    // fetchFavoritesAndProducts();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _addToFavorites(BuildContext context, String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is not logged in.')),
        );
      }
      return;
    }

    final favoriteService = FavoriteApiService();
    bool isCurrentlyFavorite = favorites[productId] ?? false;

    try {
      if (!isCurrentlyFavorite) {
        favoriteService.addToFavorites(userId, productId);
        
        setState(() {
          favorites[productId] = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm sản phẩm vào yêu thích')),
          );
        }
      } else {
        favoriteService.addToFavorites(userId, productId);
        setState(() {
          favorites[productId] = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa sản phẩm khỏi yêu thích')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  // void fetchFavoritesAndProducts() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('userId');

  //   if (userId != null) {
  //     final favoriteList =
  //         await FavoriteApiService().getFavoritesNoPopulate(userId);

  //     if (favoriteList != null) {
  //       setState(() {
  //         // Cập nhật danh sách `favoriteIds` và đồng bộ `favorites`
  //         favoriteIds =
  //             favoriteList.sanPhams.map((item) => item.idSanPham).toList();
  //         // Thiết lập `favorites` dựa trên `favoriteIds`
  //         favorites = {for (var id in favoriteIds) id: true};
  //       });
  //     }
  //   } else {
  //     print("User ID is null");
  //   }
  // }

  Future<void> fetchProducts(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final IDYeuThich = prefs.getString('IDYeuThich');
   

    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      isLoading = true;
    });

    try {
       print(IDYeuThich);
      final response = await ProductApiService().getProducts(page,
          userId: userId!, yeuthichId: IDYeuThich!);
      List<ProductModel> products = response['sanphams']
          .map<ProductModel>((json) => ProductModel.fromJSON(json))
          .where((product) => product.tinhTrang != 'Đã xóa')
          .toList();

      // Set `isFavorited` based on criteria
      for (var product in products) {
        product.isFavorited =
            product.isFavorited ?? false; // Set default or based on criteria
      }

      if (!mounted) return;
      setState(() {
        if (page == 1) {
          productList = products; // Replace the list on the first page
        } else {
          productList.addAll(products); // Add to the list on subsequent pages
        }
        totalPages = (response['totalProducts'] / productsPerPage).ceil();
        hasMore = productList.length < response['totalProducts'];
      });
    } catch (error) {
      print("Error fetching products: $error");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 300 && !isLoading && hasMore) {
      currentPage++;
      fetchProducts(currentPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 27, right: 27),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Địa chỉ",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(41, 87, 35, 1),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      size: 20,
                      Icons.location_on,
                      color: Color.fromRGBO(41, 87, 35, 1),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "18/25 Phạm Hùng, Tân Tiến",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/setting_screen');
                      },
                      child: Container(
                        width: 40,
                        height: 41,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/search_screen');
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.grey, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Color.fromRGBO(142, 198, 65, 1),
                                size: 35,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: Text(
                                  "Tìm kiếm sản phẩm ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                    SizedBox(width: 8),
                    BadgeWidget(),
                  ],
                ),
                SizedBox(height: 15),

                // Banner
                FutureBuilder<List<BannerModel>>(
                  future: bannerImage,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Center(child: Text('Không tìm thấy hình ảnh'));
                    }

                    List<BannerModel> banners = snapshot.data!;
                    return Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 5),
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: banners.map((banner) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  banner.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: banners.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => setState(() {
                                _currentIndex = entry.key;
                              }),
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Colors.black.withOpacity(
                                      _currentIndex == entry.key ? 0.9 : 0.4)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Danh mục",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color.fromRGBO(41, 87, 35, 1),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Tất cả",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category
                SizedBox(height: 120, child: CategoryWidget()),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Ưu Đãi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Ngày đếm ngược ưu đãi",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 8,
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailProductScreen(product: product, isfavorited: product.isFavorited),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Flexible(
                              child: Stack(
                                children: [
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
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        color: Color.fromRGBO(142, 198, 65, 1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "- ${product.phanTramGiamGia}%",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                        setState(() {
                                          product.isFavorited =
                                              !product.isFavorited;
                                        });
                                        _addToFavorites(context, product.id);
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: product.isFavorited
                                              ? Colors.red
                                              : Color.fromRGBO(
                                                  241, 247, 234, 1),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            product.isFavorited
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border_outlined,
                                            color: product.isFavorited
                                                ? Colors.white
                                                : Color.fromRGBO(
                                                    142, 198, 65, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Product Name and Rating
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.nameProduct,
                                      style: TextStyle(
                                        fontSize: 17,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(41, 87, 35, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber),
                                      Text("5"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Price Display
                            Padding(
                              padding: const EdgeInsets.only(top: 7.0),
                              child: Row(
                                children: [
                                  Text(
                                    '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(product.donGiaBan)} đ/kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 'Mua Ngay' Button
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
                                    border: Border.fromBorderSide(
                                      BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    color: Color.fromRGBO(41, 87, 35, 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        height: double.infinity,
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                      Expanded(
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
                  ),
                ),
                if (isLoading) // Loading Indicator
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

//                Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//     ElevatedButton(
//       onPressed: currentPage > 1
//           ? () {
//               setState(() {
//                 currentPage--;
//               });
//               fetchProducts(currentPage, isPageNavigation: true);
//             }
//           : null,
//       child: Text('Previous'),
//     ),
//     SizedBox(width: 20),
//     ElevatedButton(
//       onPressed: currentPage < totalPages
//           ? () {
//               setState(() {
//                 currentPage++;
//               });
//               fetchProducts(currentPage, isPageNavigation: true);
//             }
//           : null,
//       child: Text('Next'),
//     ),
//   ],
// )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
