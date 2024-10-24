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
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
          ),
        ),
        title: Text(
          'Giỏ hàng',
         style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1),fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Categories
                  const SizedBox(
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
