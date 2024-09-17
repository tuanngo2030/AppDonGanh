import 'package:don_ganh_app/api_services/order_api_service.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:flutter/material.dart';

class OderScreen extends StatefulWidget {
  const OderScreen({super.key});

  @override
  State<OderScreen> createState() => _OderScreenState();
}

class _OderScreenState extends State<OderScreen> {
  late Future<OrderModel> orderModel;

  @override
  void initState() {
    super.initState();
    // orderModel = OrderApiService().fetchOrder();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Đơn hàng'),
          centerTitle: true,
        ),

        body: Container(
          child: Container(
            child: ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/oder_status_screen');
              }, 
              child: Text('Click me') 
            ),
          ) 
        ),
      ),
    );
  }
}