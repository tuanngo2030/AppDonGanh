import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:don_ganh_app/widget/tb_connetInternet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TrangXinChao extends StatelessWidget {
  const TrangXinChao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 87, 35),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget> [
              // logo
              Image.asset("lib/assets/logo_xinchao.png"),
              const Text(
                'Đòn gánh xin chào!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Add space between the two texts
              const Text(
                'Ứng dụng giúp cuộc sống dễ dàng hơn, với những nông sản tươi ngon, Đòn gánh sẵn sàng phục vụ bạn mọi nơi.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 60), // Add space between text and buttons
             SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/loginscreen');
                  },
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Màu nền của nút
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Đăng nhập',style: TextStyle(color:Color.fromARGB(255, 41, 87, 35),fontSize: 15 )),
                ),
              ),
              const SizedBox(height: 10), // Add space between buttons
             SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                         onPressed: () async {
                    // Check for internet connection before navigating
                    var connectivityResult = await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.none) {
                      // If there is an internet connection, navigate to the registration screen
                      Navigator.pushNamed(context, '/registerscreen');
                    } else {
                      // If there is no internet, show a dialog to inform the user
                      checkInternetConnection(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    overlayColor: Colors.white, // Màu chữ của nút
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.white), // Màu viền của nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Bạn là người mới? Đăng ký ngay!',style: TextStyle(fontSize: 15,color: Colors.white),),
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}
