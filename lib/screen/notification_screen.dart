import 'dart:async';

import 'package:don_ganh_app/api_services/notification_api.dart';
import 'package:don_ganh_app/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  late Timer _timer;
  Map<String, bool> isDeleting =
      {}; // Track the deletion state for each notification
  @override
  void initState() {
    super.initState();
    fetchNotifications();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchNotifications(); // Periodically fetch notifications
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("Không tìm thấy userId trong SharedPreferences.");
      }

      // Call API to fetch notifications
      final data = await NotificationApi.fetchNotifications(userId);

      if (!mounted) return; // Ensure the widget is still in the tree

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        isLoading = false;
      });

      // // Show error in dialog
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text("Lỗi"),
      //     content: Text(e.toString()),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.of(context).pop(),
      //         child: const Text("Đóng"),
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  String getFormattedDate(DateTime? dateTime) {
    if (dateTime == null)
      return "Chưa có ngày"; // If the date is null, return "Chưa có ngày"

    final now = DateTime.now(); // Get the current date and time
    final difference =
        now.difference(dateTime).inDays; // Calculate the difference in days

    if (difference == 0) {
      return "Hôm nay"; // If the notification was created today, return "Hôm nay" (Today)
    } else if (difference == 1) {
      return "Hôm qua"; // If the notification was created yesterday, return "Hôm qua" (Yesterday)
    } else {
      return DateFormat('dd/MM/yyyy').format(
          dateTime); // Otherwise, return the formatted date (e.g., "01/11/2024")
    }
  }

  String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return "Không xác định";

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 1) {
      // Hiển thị ngày cụ thể nếu hơn 24 giờ
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays == 1) {
      return "Hôm qua";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours} giờ trước";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inMinutes} phút trước";
    } else {
      return "Vừa xong";
    }
  }

  void markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("Không tìm thấy userId trong SharedPreferences.");
      }

      // Gọi API để cập nhật trạng thái đã đọc
      await NotificationApi.updateAllNotificationsRead(userId);

      if (!mounted) return;

      // Cập nhật giao diện
      setState(() {
        notifications = notifications.map((notification) {
          return notification.copyWith(daDoc: true); // Đánh dấu tất cả đã đọc
        }).toList();
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tất cả thông báo đã được đánh dấu là đã đọc")),
      );
    } catch (e) {
      // Xử lý lỗi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
    }
  }

  void _showFullNotificationDialog(NotificationModel notification) async {
    if (!notification.daDoc) {
      // Gọi API để đánh dấu thông báo đã đọc
      await NotificationApi.updateNotificationRead(notification.id);

      // Cập nhật giao diện
      setState(() {
        final index =
            notifications.indexWhere((notif) => notif.id == notification.id);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(daDoc: true);
        }
      });
    }

    // Hiển thị dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.tieude),
          content: SingleChildScrollView(
            child: Text(notification.noidung), // Hiển thị toàn bộ nội dung
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Đóng Dialog
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  void deleteAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("Không tìm thấy userId trong SharedPreferences.");
      }

      // Call API to delete all notifications
      await NotificationApi.deleteAllThongBao(userId);

      if (!mounted) return;

      // Update UI
      setState(() {
        notifications.clear(); // Clear the list of notifications
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tất cả thông báo đã được xóa."),
        ),
      );
    } 
    catch (e) {
      // Handle error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _removeNotification(NotificationModel notification) async {
    try {
      // Remove notification locally
      setState(() {
        notifications.removeWhere((notif) => notif.id == notification.id);
      });

      // Call API to delete notification (optional)
      await NotificationApi.deleteThongBao(notification.id);
    } catch (e) {
      // Handle the error (e.g., show an alert, log, etc.)
      print("Error removing notification: $e");
      // You can also re-add the notification to the list in case of failure
      setState(() {
        notifications.add(notification);
      });
    }
  }

  Future<void> _showDeleteDialog(NotificationModel notification) async {
    // Tạo một bool để theo dõi trạng thái loading
    bool isLoading = false;

    // Hiển thị dialog xác nhận xóa
     showDialog<void>(
      context: context,
      barrierDismissible: false, // Người dùng phải chọn một lựa chọn
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa thông báo'),
          content: isLoading
              ? Center(
                  child:
                      CircularProgressIndicator()) // Hiển thị loading khi isLoading = true
              : Text('Bạn có chắc chắn muốn xóa thông báo này?'),
          actions: <Widget>[
            // Nút Hủy
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog nếu hủy
              },
              child: Text('Hủy'),
            ),
            // Nút Xóa
            TextButton(
              onPressed: () async {
                // Hiển thị loading khi nhấn Xóa
                setState(() {
                  isLoading = true;
                });

                // Thực hiện xóa thông báo
                await _removeNotification(notification);

                // Đóng dialog loading
                Navigator.of(context).pop();

                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa thông báo'),
                  ),
                );
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group notifications by date
    Map<String, List<NotificationModel>> groupedNotifications = {};
    for (var notification in notifications) {
      String formattedDate = getFormattedDate(notification.ngayTao);
      if (!groupedNotifications.containsKey(formattedDate)) {
        groupedNotifications[formattedDate] = [];
      }
      groupedNotifications[formattedDate]!.add(notification);
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    onPressed: markAllAsRead,
                    child: const Text(
                      "Đánh dấu tin đã đọc",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        deleteAllNotifications, // Function to delete all notifications
                    child: const Text(
                      "Xóa tất cả",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : groupedNotifications.isEmpty
                    ? const Center(child: Text("Không có thông báo nào."))
                    : ListView.builder(
                        itemCount: groupedNotifications.keys.length,
                        itemBuilder: (context, index) {
                          String dateGroup =
                              groupedNotifications.keys.elementAt(index);
                          List<NotificationModel> notificationsForDate =
                              groupedNotifications[dateGroup]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  dateGroup,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notificationsForDate.length,
                                itemBuilder: (context, index) {
                                  final notification =
                                      notificationsForDate[index];

                                  return Dismissible(
                                    key: Key(notification
                                        .id), // Use a unique key for each item
                                    onDismissed: (direction) {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      setState(() {
                                        _showDeleteDialog(notification);
                                      });
                                    },
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _showFullNotificationDialog(
                                          notification),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 16),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Avatar
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Colors.grey[300],
                                            ),
                                            const SizedBox(width: 16),
                                            // Notification content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notification.tieude,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          notification.daDoc
                                                              ? FontWeight.w500
                                                              : FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    notification.noidung,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Time
                                            Text(
                                              notification.daDoc
                                                  ? "Đã xem"
                                                  : getTimeAgo(
                                                      notification.ngayTao),
                                              style: TextStyle(
                                                color: notification.daDoc
                                                    ? Color.fromRGBO(
                                                        41, 87, 35, 1)
                                                    : Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
