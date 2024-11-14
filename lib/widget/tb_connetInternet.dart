import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void checkInternetConnection(BuildContext context) async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    // Hiển thị thông báo nếu không có kết nối
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi kết nối'),
          content: Text('Vui lòng bật kết nối internet để tiếp tục sử dụng ứng dụng.'),
          actions: <Widget>[
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                checkInternetConnection(context); // Retry the connection check
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
