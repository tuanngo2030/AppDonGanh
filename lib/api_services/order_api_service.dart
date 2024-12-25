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
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('token'); // Assuming the token is stored under the key 'token'
}

class OrderApiService {
  Future<List<OrderModel>> fetchOrder(String userId) async {
    final String baseUrl =
        "${dotenv.env['API_URL']}/hoadon/getHoaDonByUserId/$userId";

    try {
      // Get token from SharedPreferences and add it to headers
      final token = await _getTokenFromSharedPreferences();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          if (token != null)
            'Authorization': 'Bearer $token', // Add token if available
        },
      );

      if (response.statusCode == 200) {
        try {
          // In ra toàn bộ phản hồi để kiểm tra
          print('Response body order: ${response.body}');

          // Decode the JSON response
          List<dynamic> orderDataList = json.decode(response.body);

          // Convert the JSON array into a list of OrderModel
          return orderDataList
              .map((data) => OrderModel.fromJson(data))
              .toList();
        } catch (e) {
          print('Error decoding JSON: $e');
          throw Exception('Failed to decode JSON');
        }
      } else {
        // If an error occurs, throw an exception
        throw Exception('Failed to load order');
      }
    } catch (e) {
      print("Error fetching orders: $e");
      rethrow;
    }
  }

  Future<List<OrderModel>> fetchOrderForHoKinhDoanhId(String userId) async {
    final String baseUrl = "${dotenv.env['API_URL']}/hoadon/getHoaDonByHoKinhDoanhId/$userId";
    
    try {
      final token = await _getTokenFromSharedPreferences();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Authorization': 'Bearer $token', // Add token if available
        },
      );

      if (response.statusCode == 200) {
        try {
          print('Response body order: ${response.body}');
          
          // Decode the JSON response
          List<dynamic> orderDataList = json.decode(response.body);

          // Convert the JSON array into a list of OrderModel
          return orderDataList.map((data) => OrderModel.fromJson(data)).toList();
        } catch (e) {
          print('Error decoding JSON: $e');
          throw Exception('Failed to decode JSON');
        }
      } else {
        throw Exception('Failed to load order');
      }
    } catch (e) {
      print("Error fetching orders for HoKinhDoanhId: $e");
      rethrow;
    }
  }

  // Get order by HoaDonId for HoKinhDoanh
  Future<OrderModelForHoKinhDoanh> getHoaDonByHoaDonId(String hoadonId) async {
    final String url = "${dotenv.env['API_URL']}/hoadon/getHoaDonByHoaDonForHoKinhDoanhId/$hoadonId";
    
    try {
      final token = await _getTokenFromSharedPreferences();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Add token if available
        },
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final jsonData = json.decode(response.body);

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

  Future<String> updateOrderStatus(
      String hoadonId, int trangThai, String token) async {
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
        return errorResponse['message'] ??
            'Lỗi khi cập nhật trạng thái hóa đơn';
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
    String url = "${dotenv.env['API_URL']}/hoadon/createUserDiaChivaThongTinGiaoHang";

    final Map<String, dynamic> body = {
      'userId': userId,
      'diaChiMoi': diaChiMoi.toJson(),
      'ghiChu': ghiChu,
      'khuyenmaiId': khuyenmaiId,
      'mergedCart': selectedItems.toJson(),
      'TongTien': TongTien,
    };

    try {
      final token = await _getTokenFromSharedPreferences();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Add token if available
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

      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order');
    }
  }

  // Update transaction information for an order
  Future<OrderModel> updateTransactionHoaDon({
    required String hoadonId,
    required String transactionId,
    required String khuyeimaiId,
    required int giaTriGiam,
  }) async {
    final String url = "${dotenv.env['API_URL']}/hoadon/updateTransactionHoaDon/$hoadonId";

    final Map<String, dynamic> body = {
      'transactionId': transactionId,
      'khuyenmaiId': khuyeimaiId,
      'giaTriGiam': giaTriGiam,
    };

    try {
      final token = await _getTokenFromSharedPreferences();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Add token if available
        },
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['code'] == 0 && decodedResponse['data'] != null) {
          return OrderModel.fromJson(decodedResponse['data']);
        } else {
          throw Exception('API returned error: ${decodedResponse['message']}');
        }
      } else {
        print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
        throw Exception('Failed to update HoaDon');
      }
    } catch (e) {
      print('Error updating transaction: $e');
      throw Exception('Failed to update transaction');
    }
  }

  // Update transaction information for a list of orders
  Future<OrderModel> updateTransactionHoaDonList({
  required List<OrderModel> list,
  required String hoadonId,
  required String transactionId,
  required String khuyeimaiId,
  required int giaTriGiam,
}) async {
  final String url = "${dotenv.env['API_URL']}/hoadon/updateTransactionlistHoaDon";
  final List<Map<String, dynamic>> orderListJson = list.map((order) => order.toJson()).toList();

  final Map<String, dynamic> body = {
    'hoadon': orderListJson,
    'transactionId': transactionId,
    'khuyenmaiId': khuyeimaiId,
    'giaTriGiam': giaTriGiam,
  };

  try {
    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Assuming the token is saved with this key

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
      },
      body: json.encode(body),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Cập nhật thành công') {
        print('Cập nhật hóa đơn thành công');
        return OrderModel.fromJson(responseData['data']); // Adjust according to API response
      } else {
        print('Cập nhật thất bại: ${responseData['message']}');
        throw Exception('Cập nhật thất bại: ${responseData['message']}');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  } catch (e) {
    print('Error updating transaction list: $e');
    throw Exception('Failed to update transaction list');
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

  try {
    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Assuming the token is saved with this key

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
      },
      body: json.encode(body),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Cập nhật thành công') {
        print('Cập nhật hóa đơn thành công');
        return OrderModel.fromJson(responseData['data']); // Adjust according to API response
      } else {
        print('Cập nhật thất bại: ${responseData['message']}');
        throw Exception('Cập nhật thất bại: ${responseData['message']}');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  } catch (e) {
    print('Error updating transaction list: $e');
    throw Exception('Failed to update transaction list');
  }
}


 Future<dynamic> checkDonHangBaoKim({required String orderId}) async {
  final String url =
      '${dotenv.env['API_URL']}/hoadon/Checkdonhangbaokim/$orderId';

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve token

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve token

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
      },
    );

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

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve token

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['code'] == 0 && decodedResponse['data'] != null) {
        return OrderModel.fromJson(decodedResponse['data']);
      } else {
        throw Exception('API returned error: ${decodedResponse['message']}');
      }
    } else {
      print('Failed to update HoaDon: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update HoaDon');
    }
  } catch (e) {
    print('Error decoding JSON: $e');
    throw Exception('Failed to decode JSON');
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

  final Map<String, dynamic> requestBody = {
    'transactionId': transactionId,
  };

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve token

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['data'] != null) {
        return OrderModel.fromJson(responseData['data']);
      } else {
        throw Exception('API returned no data');
      }
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to update hoa don');
    }
  } catch (e) {
    print('Error occurred: $e');
    throw Exception('An error occurred while updating the transaction');
  }
}


  Future<OrderModel> updateDiaChiGhiChuHoaDon({
  required String hoadonId,
  required diaChiList diaChiMoi,
  required String ghiChu,
}) async {
  final String url =
      "${dotenv.env['API_URL']}/hoadon/updateDiaChighichuHoaDon/$hoadonId";

  final Map<String, dynamic> requestBody = {
    'diaChi': diaChiMoi.toJson(),
    'ghiChu': ghiChu,
  };

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve token

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Add token if available
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Cập nhật đơn hàng thành công');
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
    print('Lỗi khi cập nhật hóa đơn: $error');
    throw Exception('Lỗi khi cập nhật hóa đơn');
  }
}

}
