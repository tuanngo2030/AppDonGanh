import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class BadgeWidget extends StatefulWidget {
  const BadgeWidget({super.key});

  @override
  State<BadgeWidget> createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget> {
  int _currentIndex = 0;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItemCount();
  }

  void _fetchCartItemCount() async {
    try {
      CartModel cart = await CartApiService().getCart();
      int itemCount = cart.chiTietGioHang.length;
      setState(() {
        _cartItemCount = itemCount; // Cập nhật biến trạng thái
      });
    } catch (e) {
      print("Lỗi khi lấy giỏ hàng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      badgeContent: Text(
        _cartItemCount.toString(),
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
    );
  }
}
