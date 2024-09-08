// ignore_for_file: prefer_const_constructors

import 'package:don_ganh_app/api_services/cart_api_service.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<BannerModel>> bannerImage;
  late Future<List<ProductModel>> productsModel;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    bannerImage = BannerApiService().fetchBanner();
    productsModel = ProductApiService().getListProduct();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
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
                    Container(
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
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset("lib/assets/ic_search.png"),
                          ),
                          hintText: "Tìm kiếm sản phẩm",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
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
                Container(
                  height: 120, 
                  child: CategoryWidget()
                ),

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

                // List product
                FutureBuilder<List<ProductModel>>(
                  future: productsModel,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Center(child: Text('Không tìm thấy dữ liệu'));
                    }

                    List<ProductModel> products = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Tránh xung đột với cuộn của SingleChildScrollView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            print("Detail Product");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailProductScreen(product : products[index])));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 150,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      products[index].imageProduct,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        products[index].nameProduct,
                                        style: TextStyle(
                                          fontSize: 17,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w900,
                                          color: Color.fromRGBO(41, 87, 35, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),

                                    //rate
                                    Container(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          Text("5")
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '${products[index].donGiaBan} đ/kg',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                ),
                              ),

                              //Button add to cart
                              GestureDetector(
                                onTap: (){
                                  print('add to cart');
                                },
                                child: Container(
                                  height: 35,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(41, 87, 35, 1),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: 60,
                                          child: Icon(
                                            Icons.shopping_cart,
                                            color: Colors.white,
                                          )),
                                      Container(
                                        height: double.infinity,
                                        width: 1,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                        ),
                                      ),
                                      Center(
                                        child: Container(
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
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
