// category_api_service.dart
import 'package:url_launcher/url_launcher.dart';

class LoginWithApiGoogle {
  // URL để đăng nhập qua Google
  static String getGoogleAuthUrl() {
    return "https://imp-model-widely.ngrok-free.app/auth/google";
  }

  // Phương thức để mở URL đăng nhập Google trong trình duyệt
  static Future<void> launchURL(String googleAuthUrl) async {
    final Uri uri = Uri.parse(googleAuthUrl);
    
    // Kiểm tra nếu URL có thể được mở
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $googleAuthUrl';
    }
  }
}
