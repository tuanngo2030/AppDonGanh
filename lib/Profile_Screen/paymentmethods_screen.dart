import 'dart:convert';
import 'package:don_ganh_app/models/paymenthod_model.dart'; // Nhớ kiểm tra tên mô hình của bạn
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Thêm thư viện

class PaymentMethodsScreen extends StatefulWidget {
  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<BankCard> paymentMethods = [];
  List<BankCard> filteredMethods = [];
  bool isLoading = true;
  String searchQuery = "";
  int? selectedId; // Biến lưu trữ ID của mục được chọn

  @override
  void initState() {
    super.initState();
    fetchPaymentMethods();
    loadSelectedId(); // Tải ID đã lưu trước đó
  }

  // Tải ID đã chọn từ SharedPreferences
  Future<void> loadSelectedId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedId = prefs.getInt('selectedPaymentMethodId'); // Lấy ID đã lưu
    });
  }

  // Lưu ID đã chọn vào SharedPreferences
  Future<void> saveSelectedId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedPaymentMethodId', id);
  }

  Future<void> fetchPaymentMethods() async {
    final url = Uri.parse(
        'https://peacock-wealthy-vaguely.ngrok-free.app/apiBaokim/getPaymentMethods');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        PaymentResponse paymentResponse =
            PaymentResponse.fromJson(jsonResponse);

        setState(() {
          paymentMethods = paymentResponse.data;
          filteredMethods = paymentMethods;
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<BankCard> filteredList = paymentMethods.where((method) {
        return method.name.toLowerCase().contains(query.toLowerCase()) ||
            method.bankName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredMethods = filteredList;
        searchQuery = query;
      });
    } else {
      setState(() {
        filteredMethods = paymentMethods;
        searchQuery = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: const Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        title: const Text(
          'Payment Methods',
                  style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1),fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredMethods.length,
                    itemBuilder: (context, index) {
                      final method = filteredMethods[index];

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedId = method.id; // Đặt ID của mục đã chọn
                          });
                          saveSelectedId(
                              method.id!); // Lưu ID vào SharedPreferences

                          // Trả lại ID đã chọn và quay lại màn hình trước
                          Navigator.pop(context,
                              method.id); // Trả về ID phương thức thanh toán
                        },
                        child: ListTile(
                          leading: Container(
                            width: 50.0,
                            height: 50.0,
                            child: Image.network(
                              method.bankLogo,
                              fit: BoxFit.contain,
                              color: (selectedId != null &&
                                      selectedId != method.id)
                                  ? Colors.grey.withOpacity(0.5)
                                  : null, // Làm mờ các mục khác
                            ),
                          ),
                          title: Text(
                            method.name,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: (selectedId != null &&
                                      selectedId != method.id)
                                  ? Colors.grey
                                  : Colors.black, // Làm mờ chữ của mục khác
                            ),
                          ),
                          subtitle: Text(
                            method.bankName,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: (selectedId != null &&
                                      selectedId != method.id)
                                  ? Colors.grey
                                  : Colors.black, // Làm mờ phụ đề của mục khác
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
