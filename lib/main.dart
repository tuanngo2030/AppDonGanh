import 'package:don_ganh_app/Profile_Screen/dia_chi_screen.dart';
import 'package:don_ganh_app/Profile_Screen/gioitinh_screen.dart';
import 'package:don_ganh_app/Profile_Screen/gmailScreen.dart';
import 'package:don_ganh_app/Profile_Screen/ngay_sinh_Screen.dart';
import 'package:don_ganh_app/Profile_Screen/paymentmethods_screen.dart';
import 'package:don_ganh_app/Profile_Screen/profile_screen.dart';
import 'package:don_ganh_app/Profile_Screen/sodienthoai_Screen.dart';
import 'package:don_ganh_app/Profile_Screen/tenScreen.dart';
import 'package:don_ganh_app/reponsive.dart';
import 'package:don_ganh_app/screen/cach_xac_minh_tkScreen.dart';
import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:don_ganh_app/screen/creat_blog_screen.dart';
import 'package:don_ganh_app/screen/oder_status_screen.dart';
import 'package:don_ganh_app/screen/order_review_screen.dart';
import 'package:don_ganh_app/screen/otp_xac_minh_tkScreen.dart';
import 'package:don_ganh_app/screen/pay_screen/oder_screen.dart';
import 'package:don_ganh_app/screen/pay_screen/pay_screen.dart';
import 'package:don_ganh_app/screen/search_screen.dart';
import 'package:don_ganh_app/screen/setting_screen.dart';
import 'package:don_ganh_app/screen/xac_minh_tk_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/bottomnavThumua_screen.dart';
import 'package:don_ganh_app/widget/web_view.dart';
import 'package:flutter/material.dart';
import 'package:don_ganh_app/bottomnavigation.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:don_ganh_app/screen/cart_screen.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:don_ganh_app/screen/gioithieu.dart';
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:don_ganh_app/screen/new_password.dart';
import 'package:don_ganh_app/screen/otp_screen.dart';
import 'package:don_ganh_app/screen/register_screen.dart';
import 'package:don_ganh_app/screen/trang_xin_chao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: ReponsiveScreen(
      //   Mobile: CreatBlogScreen(), 
      //   Tablet: SettingScreen(), 
      //   Desktop: RegisterScreen()
      // ),
      home: BottomnavigationMenu(),
      routes: {
        '/registerscreen': (context) => RegisterScreen(),
        '/loginscreen': (context) => LoginScreen(),
        '/gioithieu': (context) => gioithieu(),
        '/new_password': (context) => NewPassword(),
        '/ban_la': (context) => BanLa(),
        '/trang_xin_chao': (context_) => TrangXinChao(),
        '/bottom': (context_) => BottomnavigationMenu(),
        '/manageraccount_screen': (context_) => ManageraccountScreen(),
        '/bottomnavigation': (context_) => BottomnavigationMenu(),
        '/cart_screen': (context_) => CartScreen(),
        '/trang_xin_chao': (context) => TrangXinChao(),
        '/bottom': (context) => BottomnavigationMenu(),
        '/manageraccount_screen': (context) => ManageraccountScreen(),
        '/ProfileScreen': (context) => ProfileScreen(),
        '/ten': (context) => Tenscreen(),
        '/NgaySinh': (context) => NgaySinh(),
        '/sodienthoai': (context) => SodienthoaiScreen(),
        '/gmail': (context) => Gmailscreen(),
        '/diachiScreen': (context) => AddressScreen(),
        '/gioitinh': (context) => GioitinhScreen(),
        '/xacminhtk': (context) => XacMinhTkScreen(),
        '/oder_screen': (context) => OderScreen(),
        // '/oder_status_screen': (context) => OderStatusScreen(),
        '/pay_screen': (context) => PayProcessScreen(),
        '/bottomThumuan': (context) => BottomnavthumuaScreen(),
        '/chatscreen': (context) => ChatScreen(title: 'Chat',),
        '/oder_review_screen': (context) => OrderReviewScreen(),
        '/setting_screen': (context) => SettingScreen(),
        '/search_screen' :(context) => SearchScreen(),
        '/creat_blog_screen' :(context) => CreatBlogScreen(),
        '/webview' :(context) => WebViewPage(),
        '/payment_screen' :(context) => PaymentMethodsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otpxacminhtk') {
          final email = settings.arguments as String?;
          if (email != null) {
            return MaterialPageRoute(
              builder: (context) => OtpXacMinhTkscreen(email: email),
            );
          }
        }
        return null;
      },
    );
  }
}
