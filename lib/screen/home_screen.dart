// ignore_for_file: prefer_const_constructors

import 'package:don_ganh_app/api_services/banner_api_service.dart';
import 'package:don_ganh_app/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<BannerModel>> bannerImage;

  @override
  void initState() {
    super.initState();
    bannerImage = BannerApiService().fetchBanner();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
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
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 41,
                    height: 42,
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
                          padding: const EdgeInsets.all(8),
                          child: Image.asset("lib/assets/ic_search.png"),
                        ),
                        hintText: "Tìm kiếm sản phẩm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  //My Cart
                  badges.Badge(
                    badgeContent: Text(
                      "0",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    badgeStyle: badges.BadgeStyle(
                        badgeColor: Color.fromRGBO(255, 0, 0, 1),
                        borderSide: BorderSide(color: Colors.white),
                        padding: EdgeInsets.all(8)),
                    child: InkWell(
                      onTap: () {
                        print("Go to my cart");
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              //Banner
              FutureBuilder<List<BannerModel>>(
                future: bannerImage,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No images found'));
                  }

                  return CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 5 ),
                      enlargeCenterPage: true,
                      viewportFraction: 1
                    ),
                    items: snapshot.data!.map((image) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(image.imageUrl,
                              fit: BoxFit.cover, 
                              width: double.infinity,),
                        ),
                      );
                    }).toList(),
                  );
                },
              )

              // Categories
              
            ],
          ),
        ),
      ),
    );
  }
}
