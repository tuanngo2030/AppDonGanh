import 'dart:convert';
import 'package:don_ganh_app/models/bank_model.dart';
import 'package:http/http.dart' as http;

class BankService {
  static const String apiUrl = 'https://api.vietqr.io/v2/banks';

  static Future<List<Bank>> fetchBanks() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> banksJson = data['data'];
      return banksJson.map((json) => Bank.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bank list');
    }
  }
}
