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
    notifyListeners(); // Thông báo cho các widget lắng nghe về sự thay đổi
  }
}