import 'package:don_ganh_app/widget/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            // leading: Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.pop(context);
            //     },
            //     child: Container(
            //       child: ImageIcon(
            //         AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
            //         size: 49, // Kích thước hình ảnh
            //       ),
            //     ),
            //   ),
            // ),
            title: Text('Cửa hàng'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: badges.Badge(
                  badgeContent: Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Color.fromRGBO(255, 0, 0, 1),
                    borderSide: BorderSide(color: Colors.white),
                    padding: EdgeInsets.all(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      print("Đi đến giỏ hàng của tôi");
                      Navigator.pushNamed(context, '/cart_screen');
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
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
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
                    ],
                  ),
                  //Categories
                  Container(
                    height: 120,
                    child: CategoryWidget(),
                  ),
                ],
              ),
            ),
          )
        ),
    );
  }
}
