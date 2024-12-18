import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/dia_chi_model.dart';
import 'package:don_ganh_app/models/oder_model_for_hokinhdoanh.dart';
import 'package:don_ganh_app/models/order_model.dart';
import 'package:don_ganh_app/models/paymentInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class OrderApiService {
  Future<List<OrderModel>> fetchOrder(String userId) async {
    final String baseUrl =
        "${dotenv.env['API_URL']}/hoadon/getHoaDonByUserId/$userId";
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

  Future<List<OrderModel>> fetchOrderForHoKinhDoanhId(String userId) async {
    final String baseUrl =
        "${dotenv.env['API_URL']}/hoadon/getHoaDonByHoKinhDoanhId/$userId";
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

  Future<OrderModelForHoKinhDoanh> getHoaDonByHoaDonId(String hoadonId) async {
    final String url =
        "${dotenv.env['API_URL']}/hoadon/getHoaDonByHoaDonForHoKinhDoanhId/$hoadonId";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final jsonData = json.decode(response.body);

        // Kiểm tra xem jsonData có phải là null không
        if (jsonData == null) {
          throw Exception('Dữ liệu trả về từ API là null');
        }

        return OrderModelForHoKinhDoanh.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Hóa đơn không tồn tại');
      } else {
        throw Exception('Không thể tải hóa đơn: ${response.body}');
      }
    } catch (error) {
      print('Lỗi khi lấy hóa đơn: $error');
      throw Exception('Lỗi khi lấy hóa đơn');
    }
  }

 Future<String> updateOrderStatus(String hoadonId, int trangThai, String token) async {
  final url =
      '${dotenv.env['API_URL']}/hoadon/updatetrangthaiHoaDOn/$hoadonId'; // Replace with your actual URL

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the token here
      },
      body: json.encode({
        'TrangThai': trangThai,
      }),
    );

    if (response.statusCode == 200) {
      // Success: Order status updated successfully
      return 'Cập nhật đơn hàng thành công';
    } else {
      // Error: Handle failure
      final errorResponse = json.decode(response.body);
      return errorResponse['message'] ?? 'Lỗi khi cập nhật trạng thái hóa đơn';
    }
  } catch (error) {
    // Catch network errors or unexpected issues
    print('Error: $error');
    return 'Lỗi kết nối mạng';
  }
}

  Future<OrderModel> createUserDiaChivaThongTinGiaoHang({
    required BuildContext context, // Add BuildContext here
    required String userId,
    required diaChiList diaChiMoi,
    required String ghiChu,
    required String khuyenmaiId,
    required double TongTien,
    required CartModel selectedItems,
  }) async {
    String url =
        "${dotenv.env['API_URL']}/hoadon/createUserDiaChivaThongTinGiaoHang";

    final Map<String, dynamic> body = {
      'userId': userId,
      'diaChiMoi': diaChiMoi.toJson(),
      'ghiChu': ghiChu,
      'khuyenmaiId': khuyenmaiId,
      'mergedCart': selectedItems.toJson(),
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

    if (response.statusCode == 200) {
      final paymentInfo = Provider.of<PaymentInfo>(context, listen: false);
      final responseData = json.decode(response.body);
      final List<OrderModel> orders = (responseData['hoadon'] as List)
          .map((data) => OrderModel.fromJson(data))
          .toList();
      paymentInfo.setOrders(orders);
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
    required String khuyeimaiId,
    required int giaTriGiam,
  }) async {
    final String url =
        "${dotenv.env['API_URL']}/hoadon/updateTransactionHoaDon/$hoadonId";

    final Map<String, dynamic> body = {
      'transactionId': transactionId,
      'khuyenmaiId': khuyeimaiId,
      'giaTriGiam': giaTriGiam,
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

  Future<OrderModel> updateTransactionHoaDonList({
    required List<OrderModel> list,
    required String hoadonId,
    required String transactionId,
    required String khuyeimaiId,
    required int giaTriGiam,
  }) async {
    final String url =
        "${dotenv.env['API_URL']}/hoadon/updateTransactionlistHoaDon";
    final List<Map<String, dynamic>> orderListJson =
        list.map((order) => order.toJson()).toList();

    final Map<String, dynamic> body = {
      'hoadon': orderListJson,
      'transactionId': transactionId,
      'khuyenmaiId': khuyeimaiId,
      'giaTriGiam': giaTriGiam,
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
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Cập nhật thành công') {
        print('Cập nhật hóa đơn thành công');
        return responseData['message']; // Điều chỉnh theo API response nếu cần
      } else {
        print('Cập nhật thất bại: ${responseData['message']}');
        throw Exception('Cập nhật thất bại: ${responseData['message']}');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  }

  Future<OrderModel> updateTransactionHoaDonCODList({
    required List<OrderModel> list,
    required String hoadonId,
    required String transactionId,
    required String khuyeimaiId,
    required int giaTriGiam,
  }) async {
    final String url =
        "${dotenv.env['API_URL']}/hoadon/updateTransactionListHoaDonCOD";
    final List<Map<String, dynamic>> orderListJson =
        list.map((order) => order.toJson()).toList();

    final Map<String, dynamic> body = {
      'hoadon': orderListJson,
      'transactionId': transactionId,
      'khuyenmaiId': khuyeimaiId,
      'giaTriGiam': giaTriGiam,
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
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Cập nhật thành công') {
        print('Cập nhật hóa đơn thành công');
        return OrderModel.fromJson(
            responseData['data']); // Điều chỉnh theo API response nếu cần
      } else {
        print('Cập nhật thất bại: ${responseData['message']}');
        throw Exception('Cập nhật thất bại: ${responseData['message']}');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  }

  Future<dynamic> checkDonHangBaoKim({required String orderId}) async {
    final String url =
        '${dotenv.env['API_URL']}/hoadon/Checkdonhangbaokim/$orderId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Check Order Response Status: ${response.statusCode}');
      print('Check Order Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        throw Exception('Order expired');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to check order');
      }
    } catch (e) {
      print('Error checking order: $e');
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> cancelOrder(String hoadonId) async {
    final String url = '${dotenv.env['API_URL']}/hoadon/HuyDonHang/$hoadonId';

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Order canceled successfully');
      } else {
        print('Failed to cancel order: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<OrderModel> updateTrangThaiHoaDon({
    required String hoadonId,
  }) async {
    final String url =
        "${dotenv.env['API_URL']}/hoadon/updateTransactionHoaDon/$hoadonId";

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
    required String khuyeimaiId,
    required int giaTriGiam,
  }) async {
    final String url =
        "${dotenv.env['API_URL']}/hoadon/updateTransactionHoaDonCOD/$hoadonId";

    // Request body (transactionId)
    final Map<String, dynamic> requestBody = {
      'transactionId': transactionId,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json'
        }, // Add appropriate headers
        body: jsonEncode(requestBody), // Convert request body to JSON
      );

      // Check the response status and body
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Assuming the API returns the updated hoa don data in the 'data' field
        if (responseData['data'] != null) {
          return OrderModel.fromJson(responseData['data']);
        } else {
          throw Exception('API returned no data');
        }
      } else {
        // Handle error response
        print("Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to update hoa don');
      }
    } catch (e) {
      // Handle exceptions, such as network errors
      print('Error occurred: $e');
      throw Exception('An error occurred while updating the transaction');
    }
  }

  Future<OrderModel> updateDiaChiGhiChuHoaDon({
    required String hoadonId,
    required diaChiList diaChiMoi,
    required String ghiChu,
  }) async {
    // URL của API Node.js
    final String url =
        "${dotenv.env['API_URL']}/hoadon/updateDiaChighichuHoaDon/$hoadonId";

    // Body của request
    final Map<String, dynamic> requestBody = {
      'diaChi': diaChiMoi.toJson(),
      'ghiChu': ghiChu,
    };

    try {
      // Gửi yêu cầu POST tới server Node.js
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Định dạng JSON
        },
        body: jsonEncode(requestBody),
      );

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        print('Cập nhật đơn hàng thành công');

        // Giả sử bạn có một phương thức để chuyển response.body thành OrderModel
        final order = OrderModel.fromJson(jsonDecode(response.body));
        return order;
      } else if (response.statusCode == 404) {
        print('Đơn hàng không tồn tại');
        throw Exception('Đơn hàng không tồn tại');
      } else if (response.statusCode == 400) {
        print('Cập nhật không hợp lệ');
        throw Exception('Cập nhật không hợp lệ');
      } else {
        print('Lỗi không xác định: ${response.body}');
        throw Exception('Lỗi không xác định');
      }
    } catch (error) {
      // Xử lý lỗi trong trường hợp không kết nối được tới server
      print('Lỗi khi cập nhật hóa đơn: $error');
      throw Exception('Lỗi khi cập nhật hóa đơn');
    }
  }
}
