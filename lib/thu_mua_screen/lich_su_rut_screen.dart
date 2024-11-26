import 'dart:async';

import 'package:don_ganh_app/api_services/rut_tien_api_service.dart';
import 'package:don_ganh_app/models/yeu_cau_rut_tien_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LichSuRutScreen extends StatefulWidget {
  const LichSuRutScreen({super.key});

  @override
  State<LichSuRutScreen> createState() => _LichSuRutScreenState();
}

class _LichSuRutScreenState extends State<LichSuRutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamController<List<WithdrawalRequest>> _requestsStreamController;
  late Stream<List<WithdrawalRequest>> withdrawalRequestsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize StreamController inside initState
    _requestsStreamController = StreamController<List<WithdrawalRequest>>();
    withdrawalRequestsStream = _requestsStreamController.stream;

    _initializeData();
    // startTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _requestsStreamController.close(); // Close the StreamController when no longer needed
    super.dispose();
  }

  // void startTimer() {
  //   Timer.periodic(const Duration(seconds: 1), (timer) {
  //     _initializeData(); // Fetch new data without loading spinner
  //   });
  // }

 Future<void> _initializeData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');

  if (userId != null) {
    try {
      final requests = await YeuCauRutTienApi()
          .getListYeuCauRutTienByuserId(userId);
      requests.sort((a, b) => b.ngayYeuCau.compareTo(a.ngayYeuCau));

      // Check if the StreamController is closed
      if (!_requestsStreamController.isClosed) {
        _requestsStreamController.add(requests);
      }
    } catch (e) {
      if (!_requestsStreamController.isClosed) {
        _requestsStreamController.addError(e);
      }
    }
  } else {
    if (!_requestsStreamController.isClosed) {
      _requestsStreamController.addError('User ID not found in SharedPreferences');
    }
  }
}

void _handleDeleteRequest(WithdrawalRequest request) async {
  // Confirm deletion with the user before proceeding
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  // If user confirmed the deletion
  if (confirm == true) {
    try {
      // Call the API to delete the request
      final result = await YeuCauRutTienApi().deleteWithdrawalRequest(request.id);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Request deleted successfully')),
      );

      // Refresh the data to reflect the change
      _initializeData();
    } catch (e) {
      // Handle error and show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request: $e')),
      );
    }
  }
}

  // Function to filter requests
  List<WithdrawalRequest> filterRequests(
      List<WithdrawalRequest> requests, bool isCompleted) {
    return requests.where((request) => request.daXuLy == isCompleted).toList();
  }

  // Function to format currency
  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫'); // Vietnamese Dong
    return formatter.format(amount);
  }

  Widget buildRequestList(List<WithdrawalRequest> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text('Không có yêu cầu nào.'));
    }

    final groupedRequests = groupRequestsByDate(requests);

    return ListView(
      children: groupedRequests.entries.map((entry) {
        final String date = entry.key;
        final List<WithdrawalRequest> requestsForDate = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ...requestsForDate.map((request) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                    title: Text('Ngân hàng: ${request.tenNganHang}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số tài khoản: ${request.soTaiKhoan}'),
                        Text(
                            'Số tiền: ${formatCurrency(request.soTien.toDouble())}'),
                      ],
                    ),
                    trailing: request.xacThuc
                        ? const Text('Đã xác nhận',
                            style: TextStyle(
                                color: Colors.green)) // Nếu yêu cầu đã xác nhận, không có PopupMenu
                        : PopupMenuButton<String>( 
                            onSelected: (String value) async {
                              if (value == 'cancel') {
                                _handleDeleteRequest(request);
                              }
                              if (value == 'resendMail') {
                                // Gọi API gửi lại email xác thực
                                final result = await YeuCauRutTienApi()
                                    .resendYeuCauRutTien(request.id);

                                // Hiển thị kết quả thông báo
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result['message'] ?? 'Email xác thực đã được gửi lại')) 
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'cancel',
                                child: Text('Hủy'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'resendMail',
                                child: Text('Gửi lại mail xác thực'),
                              ),
                            ],
                          )),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Map<String, List<WithdrawalRequest>> groupRequestsByDate(
      List<WithdrawalRequest> requests) {
    final Map<String, List<WithdrawalRequest>> groupedRequests = {};
    final DateTime now = DateTime.now();

    for (var request in requests) {
      String key;

      if (DateFormat('yyyy-MM-dd').format(request.ngayYeuCau) ==
          DateFormat('yyyy-MM-dd').format(now)) {
        key = 'Hôm nay';
      } else if (DateFormat('yyyy-MM-dd').format(request.ngayYeuCau) == 
          DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 1)))) {
        key = 'Hôm qua';
      } else {
        key = DateFormat('dd/MM/yyyy').format(request.ngayYeuCau);
      }

      if (groupedRequests.containsKey(key)) {
        groupedRequests[key]!.add(request);
      } else {
        groupedRequests[key] = [request];
      }
    }

    return groupedRequests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử rút tiền'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chưa xử lý'),
            Tab(text: 'Đã hoàn thành'),
          ],
        ),
      ),
      body: StreamBuilder<List<WithdrawalRequest>>(
        stream: withdrawalRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final List<WithdrawalRequest> requests = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                buildRequestList(filterRequests(requests, false)),
                buildRequestList(filterRequests(requests, true)),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
