import 'dart:convert';
import 'package:don_ganh_app/api_services/yeu_cau_rut_tien_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class YeuCauRutTienApi {

  Future<List<WithdrawalRequest>> getListYeuCauRutTienByuserId(String userId) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/user/getListYeuCauRutTienByuserId/$userId'); // Ensure the URL is correct

  try {
    // Send GET request to the API
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Check if 'requests' key exists and has values
      if (data['data'] != null) {
        // Parse the list of withdrawal requests into a list of models
        List<WithdrawalRequest> withdrawalRequests = (data['data'] as List)
            .map((requestData) => WithdrawalRequest.fromJson(requestData))
            .toList();

        return withdrawalRequests;
      } else {
        // Return an empty list if no requests are found
        return [];
      }
    } else {
      // Handle non-200 status codes
      throw Exception('Failed to fetch withdrawal requests');
    }
  } catch (error) {
    throw Exception('Failed to fetch withdrawal requests: $error');
  }
}


  Future<Map<String, dynamic>> createYeuCauRutTien({
  required String userId,
  required String tenNganHang,
  required String soTaiKhoan,
  required double soTien,
  String? ghiChu,
}) async {
  final url = Uri.parse('${dotenv.env['API_URL']}/user/createYeuCauRutTien'); // Replace with your Node.js API URL

  try {
    // Prepare request data
    final requestBody = {
      'userId': userId,
      'tenNganHang': tenNganHang,
      'soTaiKhoan': soTaiKhoan,
      'soTien': soTien,
      'ghiChu': ghiChu ?? '', // Use empty string if ghiChu is null
    };

    // Send POST request to the API
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'],
        'request': data['request'],
      };
    } else {
      final data = json.decode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'An error occurred',
      };
    }
  } catch (error) {
    return {
      'success': false,
      'message': 'Failed to create withdrawal request: $error',
    };
  }
}

}

