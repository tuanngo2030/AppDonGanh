import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class BadgeWidget extends StatefulWidget {
  final GlobalKey<BadgeWidgetState> badgeKey;

  const BadgeWidget({super.key, required this.badgeKey});

  @override
  State<BadgeWidget> createState() => BadgeWidgetState();
}

class BadgeWidgetState extends State<BadgeWidget> {
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItemCount();
  }

  void _fetchCartItemCount() async {
    try {
      List<CartModel> carts = await CartApiService().getGioHangByUserId();
      int itemCount = 0;
      for (var cart in carts) {
        for (var item in cart.mergedCart) {
          for (var product in item.sanPhamList) {
            itemCount += product.chiTietGioHangs.length;
          }
        }
      }
      setState(() {
        _cartItemCount = itemCount;
      });
    } catch (e) {
      print("Lỗi khi lấy giỏ hàng: $e");
    }
  }

   void refreshCartItemCount() {
    _fetchCartItemCount(); // Fetch the latest cart item count
  }

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      badgeContent: Text(
        _cartItemCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      badgeStyle: const badges.BadgeStyle(
        badgeColor: Color.fromRGBO(255, 0, 0, 1),
        borderSide: BorderSide(color: Colors.white),
        padding: EdgeInsets.all(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/cart_screen');
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color.fromRGBO(41, 87, 35, 1),
          ),
          child: const Icon(
            Icons.shopping_bag,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
