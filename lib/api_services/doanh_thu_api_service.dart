import 'dart:convert';
import 'package:don_ganh_app/models/doanh_thu_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, Revenue>> getRevenue({
  required String fromDate,
  required String toDate,
  required String filter,
}) async {


  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/doanhthu/GetDoanhThu?filter=$filter'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    
    // Map the response to the Revenue model
    return data.map((key, value) => MapEntry(
      key,
      Revenue.fromMap(key, value),
    ));
  } else {
    throw Exception('Failed to load revenue data');
  }
}
