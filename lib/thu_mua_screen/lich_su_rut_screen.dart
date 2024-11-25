import 'package:don_ganh_app/api_services/rut_tien_api_service.dart';
import 'package:don_ganh_app/api_services/yeu_cau_rut_tien_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:intl/intl.dart'; // Import intl package

class LichSuRutScreen extends StatefulWidget {
  const LichSuRutScreen({super.key});

  @override
  State<LichSuRutScreen> createState() => _LichSuRutScreenState();
}

class _LichSuRutScreenState extends State<LichSuRutScreen> {
  Future<List<WithdrawalRequest>>? withdrawalRequestsFuture;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      setState(() {
        withdrawalRequestsFuture =
            YeuCauRutTienApi().getListYeuCauRutTienByuserId(userId);
      });
    } else {
      setState(() {
        withdrawalRequestsFuture = Future.error('User ID not found in SharedPreferences');
      });
    }
  }

  // Function to group requests by date
  Map<String, List<WithdrawalRequest>> groupRequestsByDate(List<WithdrawalRequest> requests) {
    final Map<String, List<WithdrawalRequest>> groupedRequests = {};
    final DateTime now = DateTime.now();

    for (var request in requests) {
      String key;

      if (DateFormat('yyyy-MM-dd').format(request.ngayYeuCau) == DateFormat('yyyy-MM-dd').format(now)) {
        key = 'Hôm nay';
      } else if (DateFormat('yyyy-MM-dd').format(request.ngayYeuCau) ==
          DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)))) {
        key = 'Hôm qua';
      } else {
        key = DateFormat('dd/MM/yyyy').format(request.ngayYeuCau); // Group by exact date
      }

      if (groupedRequests.containsKey(key)) {
        groupedRequests[key]!.add(request);
      } else {
        groupedRequests[key] = [request];
      }
    }

    return groupedRequests;
  }

  // Function to format currency
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫'); // Vietnamese Dong
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử rút tiền'),
      ),
      body: withdrawalRequestsFuture == null
          ? const Center(child: CircularProgressIndicator()) // Show loading if the future is not initialized
          : FutureBuilder<List<WithdrawalRequest>>(
              future: withdrawalRequestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData) {
                  final List<WithdrawalRequest> requests = snapshot.data!;
                  if (requests.isNotEmpty) {
                    final groupedRequests = groupRequestsByDate(requests);

                    return ListView(
                      children: groupedRequests.entries.map((entry) {
                        final String date = entry.key;
                        final List<WithdrawalRequest> requestsForDate = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            // Requests for that date
                            ...requestsForDate.map((request) {
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: ListTile(
                                  title: Text('Ngân hàng: ${request.tenNganHang}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Số tài khoản: ${request.soTaiKhoan}'),
                                      Text('Số tiền: ${formatCurrency(request.soTien.toDouble())}'),
                                    ],
                                  ),
                                  trailing: Text(
                                    request.daXuLy ? 'Đã xử lý' : 'Chưa xử lý',
                                    style: TextStyle(
                                      color: request.daXuLy ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(child: Text('No requests found.'));
                  }
                }

                return const Center(child: Text('No data available'));
              },
            ),
    );
  }
}
