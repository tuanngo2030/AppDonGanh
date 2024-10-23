import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderApiService {
  Future<List<OrderModel>> fetchOrder(String userId) async {
    final String baseUrl =
        "https://peacock-wealthy-vaguely.ngrok-free.app/api/hoadon/getHoaDonByUserId/$userId";
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      try {
        // In ra toàn bộ phản hồi để kiểm tra
        print('Response body order: ${response.body}');

        // Giải mã JSON nhận được
        List<dynamic> orderDataList = json.decode(response.body);

        // Chuyển đổi mảng JSON thành danh sách OrderModel
        return orderDataList.map((data) => OrderModel.fromJson(data)).toList();
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      // Nếu gặp lỗi, ném ra ngoại lệ.
      throw Exception('Failed to load order');
    }
  }

  Future<OrderModel> createUserDiaChivaThongTinGiaoHang({
    required String userId,
    required diaChiList diaChiMoi,
    required String ghiChu,
    required String khuyenmaiId,
    required double TongTien,
    required List<ChiTietGioHang> selectedItems,
    // required String YeuCauNhanHang,
  }) async {
    const String url =
        "https://peacock-wealthy-vaguely.ngrok-free.app/api/hoadon/createUserDiaChivaThongTinGiaoHang";

    final Map<String, dynamic> body = {
      'userId': userId,
      'diaChiMoi': diaChiMoi.toJson(),
      'ghiChu': ghiChu,
      'khuyenmaiId': khuyenmaiId,
      'ChiTietGioHang': selectedItems.map((item) => item.toJson()).toList(),
      // 'YeuCauNhanHang': YeuCauNhanHang,
      'TongTien': TongTien,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      print('Failed to create HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create HoaDon');
    }

    if (response.body.isEmpty) {
      throw Exception('Response body is empty');
    }

    try {
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error decoding JSON: $e');
      throw Exception('Failed to decode JSON');
    }
  }

  Future<OrderModel> updateTransactionHoaDon({
    required String hoadonId,
    required String transactionId,
  }) async {
    final String url =
        "https://peacock-wealthy-vaguely.ngrok-free.app/api/hoadon/updateTransactionHoaDon/$hoadonId";

    final Map<String, dynamic> body = {
      'transactionId': transactionId,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['code'] == 0 && decodedResponse['data'] != null) {
          return OrderModel.fromJson(decodedResponse['data']);
        } else {
          throw Exception('API returned error: ${decodedResponse['message']}');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  }

  Future<dynamic> checkDonHangBaoKim({
    required String orderId,
  }) async {
    final String url =
        'https://peacock-wealthy-vaguely.ngrok-free.app/api/hoadon/Checkdonhangbaokim/$orderId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Check Order Response Status: ${response.statusCode}');
    print('Check Order Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return data;
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      print('Failed to check order: ${response.statusCode} ${response.body}');
      throw Exception('Failed to check order');
    }
  }

  Future<OrderModel> updateTrangThaiHoaDon({
    required String hoadonId,
  }) async {
    final String url =
        "https://peacock-wealthy-vaguely.ngrok-free.app/api/hoadon/updateTransactionHoaDon/$hoadonId";

    final response = await http.post(
      Uri.parse(url),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['code'] == 0 && decodedResponse['data'] != null) {
          return OrderModel.fromJson(decodedResponse['data']);
        } else {
          throw Exception('API returned error: ${decodedResponse['message']}');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  }

 Future<OrderModel> updateTransactionHoaDonCOD({
  required String hoadonId,
  required String transactionId,
}) async {
  final String url =
      "https://peacock-wealthy-vaguely.ngrok-free.app/api/hoadon/updateTransactionHoaDonCOD/$hoadonId";

  final Map<String, dynamic> body = {
    'transactionId': transactionId,
  };

  try {
    // Making the HTTP PUT request to update the invoice
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    // Logging the response status and body for debugging
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handling the response based on the HTTP status code
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      print('Decoded Response: $decodedResponse');

      // Checking if the API call was successful
      if (decodedResponse['message'] == 'Cập nhật hóa đơn thành công' && decodedResponse['data'] != null) {
        return OrderModel.fromJson(decodedResponse['data']);
      } else {
        throw Exception('API returned error: ${decodedResponse['message']}');
      }
    } else {
      // Handling non-200 responses
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  } catch (e) {
    // Catching and handling any potential errors
    print('Error: $e');
    throw Exception('Error occurred during the API call');
  }
}
}
