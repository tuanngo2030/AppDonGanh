import 'dart:ffi';

import 'package:device_preview/device_preview.dart';
import 'package:don_ganh_app/CreatPassword/sendotpcreatPw.dart';
import 'package:don_ganh_app/screen/checkbot.dart';
import 'package:don_ganh_app/screen/ho_tro_khach_hang_screen.dart';
import 'package:don_ganh_app/service/notification_service.dart';
import 'package:don_ganh_app/thu_mua_screen/dang_ky_thu_mua_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/doanh_thu_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/lich_su_rut_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/other_profile_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/quan_ly_don_hang_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/so_du_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/thong_tin_tai_khoan_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/your_blog_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:don_ganh_app/Profile_Screen/bao_mat.dart';
import 'package:don_ganh_app/Profile_Screen/dia_chi_screen.dart';
import 'package:don_ganh_app/Profile_Screen/gioitinh_screen.dart';
import 'package:don_ganh_app/Profile_Screen/gmailScreen.dart';
import 'package:don_ganh_app/Profile_Screen/ngay_sinh_Screen.dart';
import 'package:don_ganh_app/Profile_Screen/paymentmethods_screen.dart';
import 'package:don_ganh_app/Profile_Screen/profile_screen.dart';
import 'package:don_ganh_app/Profile_Screen/resetpassword.dart';
import 'package:don_ganh_app/Profile_Screen/sodienthoai_Screen.dart';
import 'package:don_ganh_app/Profile_Screen/tenScreen.dart';
import 'package:don_ganh_app/Profile_Screen/them_the_ngan_hang.dart';
import 'package:don_ganh_app/forgotpassword_screen/sendotpgmail.dart';
import 'package:don_ganh_app/screen/cach_xac_minh_tkScreen.dart';
import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:don_ganh_app/screen/creat_blog_screen.dart';
import 'package:don_ganh_app/screen/khuyen_mai_screen.dart';
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
import 'package:don_ganh_app/bottomnavigation.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/ban_la.dart';
import 'package:don_ganh_app/screen/cart_screen.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:don_ganh_app/screen/gioithieu.dart';
import 'package:don_ganh_app/screen/login_screen.dart';
import 'package:don_ganh_app/screen/manageraccount_screen.dart';
import 'package:don_ganh_app/forgotpassword_screen/new_password.dart';
import 'package:don_ganh_app/forgotpassword_screen/otp_screen.dart';
import 'package:don_ganh_app/screen/register_screen.dart';
import 'package:don_ganh_app/screen/trang_xin_chao.dart';

// void main() async {
//   await dotenv.load(fileName: "lib/.env");
//   runApp(
//     // const MyApp(),
//     DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => ChangeNotifierProvider(
//         create: (context) => PaymentInfo(),
//         child: const MyApp(),
//       ),
//     ),
//   );
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  await dotenv.load(fileName: "lib/.env");
  
  runApp(

    ChangeNotifierProvider(
      create: (context) => PaymentInfo(),
      child: const MyApp(),
    ),
  
  );
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // Register the RouteObserver here
      home: const gioithieu(),
      routes: {
        '/registerscreen': (context) => const RegisterScreen(),
        '/loginscreen': (context) => const LoginScreen(),
        '/gioithieu': (context) => const gioithieu(),
        '/new_password': (context) => const NewPassword(),
        '/ban_la': (context) => const BanLa(),
        '/trang_xin_chao': (context_) => const TrangXinChao(),
        '/bottom': (context_) => const BottomnavigationMenu(),
        '/manageraccount_screen': (context_) => const ManageraccountScreen(),
        '/bottomnavigation': (context_) => const BottomnavigationMenu(),
        '/cart_screen': (context_) => const CartScreen(),
        '/ProfileScreen': (context) => const ProfileScreen(),
        '/ten': (context) => const Tenscreen(),
        '/NgaySinh': (context) => const NgaySinh(),
        '/sodienthoai': (context) => const SodienthoaiScreen(),
        '/gmail': (context) => const Gmailscreen(),
        '/diachiScreen': (context) => const AddressScreen(),
        '/gioitinh': (context) => const GioitinhScreen(),
        '/oder_screen': (context) => const OderScreen(),
        '/pay_screen': (context) => const PayProcessScreen(),
        '/bottomThumua': (context) => const BottomnavthumuaScreen(),
        '/setting_screen': (context) => const SettingScreen(),
        '/search_screen': (context) => const SearchScreen(),
        '/creat_blog_screen': (context) => const CreatBlogScreen(),
        '/webview': (context) => const WebViewPage(),
        '/payment_screen': (context) => const PaymentMethodsScreen(),
        '/CardLinkScreen': (context) => CardLinkScreen(),
        '/SecurityScreen': (context) => SecurityScreen(),
        '/Sendotpgmail': (context) => Sendotpgmail(),
        '/Resetpassword': (context) => const Resetpassword(),
        // '/Checkbot': (context) => const Checkbot(),
        '/your_blog_screen': (context) => const YourBlogScreen(),
        '/dang_ky_thu_mua_screen': (context) => const DangKyThuMuaScreen(),
        '/so_du_screen': (context) => const SoDuScreen(),
        '/yeu_cau_rut_screen': (context) => const LichSuRutScreen(),
        '/so_du_screen': (context) => const SoDuScreen(),
        '/sendotpcreate_screen': (context) => Sendotpcreatpw(),
        '/quan_ly_don_hang_screen': (context) => const QuanLyDonHangScreen(),
        '/ho_tro_khach_hang_screen': (context) => const HoTroKhachHangScreen(),
        '/thong_tin_tai_khoan_screen': (context) => const ThongTinTaiKhoanScreen(),
        // '/other_profile_screen': (context) => const O(),
        
        
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
        if (settings.name == '/xacminhtk') {
          final email = settings.arguments as String?;
          if (email != null) {
            return MaterialPageRoute(
              builder: (context) => XacMinhTkScreen(email: email),
            );
          }
        }
        
        return null;
      },
    );
  }
}
