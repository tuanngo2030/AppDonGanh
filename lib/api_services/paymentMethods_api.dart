import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> getPaymentMethods() async {
  final url = Uri.parse('https://imp-model-widely.ngrok-free.app/apiBaokim/getPaymentMethods');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Payment Methods: $data');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

