import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool quyenVT = false;
  bool quyenMic = false;
  bool quyenLibra = false;
  bool quyenCam = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
         appBar: AppBar(
          elevation: 0,
          title: Text(
            'Cài đặt',
            style: TextStyle(
              color: Color.fromRGBO(59, 99, 53, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: [
              Divider(thickness: 1),
              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập vị trí'),
                value: quyenVT, 
                onChanged: (bool value){
                  setState(() {
                    quyenVT = value;
                  });
                },
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để chúng tôi có thể nhanh chóng giao hàng cho bạn',
                      style: TextStyle(
                        fontSize: 11
                      ),
                    ),
                  ),
                ),
              ),

              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập Micro'),
                value: quyenMic, 
                onChanged: (bool value){
                  setState(() {
                    quyenMic = value;
                  });
                },
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để chúng tôi có thể dễ dàng trao đổi với nhân viên của chúng tôi',
                       style: TextStyle(
                        fontSize: 11
                      ),
                    ),
                  ),
                ),
              ),

              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập thư viện ảnh'),
                value: quyenLibra, 
                onChanged: (bool value){
                  setState(() {
                    quyenLibra = value;
                  });
                },
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                 color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để bạn có thể dễ dàng gửi đánh giá sản phẩm và cập nhật ảnh đai diện cho tài khoản của mình',
                       style: TextStyle(
                        fontSize: 11
                      ),
                    ),
                  ),
                ),
              ),

              SwitchListTile(
                title: Text('Cho phép Đòn Gánh truy cập máy ảnh'),
                value: quyenCam, 
                onChanged: (bool value) async {
                  PermissionStatus status = await Permission.camera.request();

                  if(status == PermissionStatus.granted){
                    debugPrint('Permission granted');
                    setState(() {
                      quyenCam = value;
                    });
                  }if(status == PermissionStatus.denied){
                    debugPrint('Permission denied');
                  }if(status == PermissionStatus.limited){
                    debugPrint('Permission limited');
                  }if(status == PermissionStatus.restricted){
                    debugPrint('Permission Restricted');
                  }
                },
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'Để bạn có thể dễ dàng gửi đánh giá sản phẩm và cập nhật ảnh đai diện cho tài khoản của mình',
                       style: TextStyle(
                        fontSize: 11
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}