import 'package:don_ganh_app/models/cart_model.dart';
import 'package:flutter/material.dart';

class PaymentInfo with ChangeNotifier {
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
  List<ChiTietGioHang> selectedItems = [];
  double totalPrice = 0;
  String assetPath = '';
  String title = '';
  String? subtitle;
  String payment_url = '';

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
    required List<ChiTietGioHang> selectedItems,
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
    notifyListeners(); // Thông báo cho các widget lắng nghe về sự thay đổi
  }

  void paymentMehtod({
    required String assetPath,
    required String title,
    required String? subtitle,
    required String payment_url,
  }) {
    this.assetPath = assetPath;
    this.title = title;
    this.subtitle = subtitle;
    this.payment_url = payment_url;
    notifyListeners();
  }
}
