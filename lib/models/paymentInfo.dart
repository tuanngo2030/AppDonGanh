import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:flutter/material.dart';

class PaymentInfo with ChangeNotifier {
   List<OrderModel> _orders = [];
  String order_id = '';
  String hoTen = '';
  String soDienThoai = '';
  String email = '';
  String yeuCauNhanHang = '';
  String? tinhThanhPho;
  String? quanHuyen;
  String? phuongXa;
  String duongThonXom = '';
  String ghiChu = '';
  int transitionID = 0;
  late CartModel selectedItems;
  double totalPrice = 0;
  String assetPath = '';
  String title = '';
  String? subtitle;
  String payment_url = '';
  int giaTriGiam = 0;

  void updateInfo({
    required String order_id,
    required String hoTen,
    required String soDienThoai,
    required String email,
    required String yeuCauNhanHang,
    String? tinhThanhPho,
    String? quanHuyen,
    String? phuongXa,
    required String duongThonXom,
    required String ghiChu,
    required CartModel selectedItems,
    required double totalPrice,
  }) {
    this.order_id = order_id;
    this.hoTen = hoTen;
    this.soDienThoai = soDienThoai;
    this.email = email;
    this.yeuCauNhanHang = yeuCauNhanHang;
    this.tinhThanhPho = tinhThanhPho;
    this.quanHuyen = quanHuyen;
    this.phuongXa = phuongXa;
    this.duongThonXom = duongThonXom;
    this.ghiChu = ghiChu;
    this.selectedItems = selectedItems;
    this.totalPrice = totalPrice;

    // Call notifyListeners() safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void paymentMehtod({
    required String assetPath,
    required String title,
    required String? subtitle,
    required String payment_url,
    required int giaTriGiam,
  }) {
    this.assetPath = assetPath;
    this.title = title;
    this.subtitle = subtitle;
    this.payment_url = payment_url;
    this.giaTriGiam = giaTriGiam;

    // Call notifyListeners() safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Hàm để làm trống toàn bộ dữ liệu
  void reset() {
    order_id = '';
    hoTen = '';
    soDienThoai = '';
    email = '';
    yeuCauNhanHang = '';
    tinhThanhPho = '';
    quanHuyen = '';
    phuongXa = '';
    duongThonXom = '';
    ghiChu = '';
    selectedItems;
    totalPrice = 0.0;
    payment_url = '';
    assetPath = '';
    title = '';
    subtitle = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

    

  List<OrderModel> get orders => _orders;

  void setOrders(List<OrderModel> orders) {
    _orders = orders;
    notifyListeners();
  }

  void addOrder(OrderModel order) {
    _orders.add(order);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
