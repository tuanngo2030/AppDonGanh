import 'package:don_ganh_app/api_services/khuyen_mai_api_service.dart';
import 'package:don_ganh_app/models/khuyen_mai_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:intl/intl.dart';

class KhuyenMaiScreen extends StatefulWidget {
  final int totalAmount;
  final Function(KhuyenMaiModel) onPromotionSelected;
  const KhuyenMaiScreen({
    super.key,
    required this.totalAmount,
    required this.onPromotionSelected,
  });

  @override
  State<KhuyenMaiScreen> createState() => _KhuyenMaiScreenState();
}

class _KhuyenMaiScreenState extends State<KhuyenMaiScreen> {
  late Future<List<KhuyenMaiModel>> _futureVouchers;

  @override
  void initState() {
    super.initState();
    _futureVouchers =
        KhuyenMaiApiService().fetchPromotionList(widget.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFEFEFEF),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back,
      //         color: Color.fromRGBO(41, 87, 35, 1)),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: const Text(
      //     'Voucher',
      //     style: TextStyle(color: Color.fromRGBO(41, 87, 35, 1)),
      //   ),
      //   centerTitle: true,
      // ),
      body: FutureBuilder<List<KhuyenMaiModel>>(
        future: _futureVouchers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No promotions available'));
          } else {
            final vouchers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                final isEligible = voucher
                    .isEligible; // Assume 'isEligible' is a boolean property

                // Format giaTriKhuyenMai with dot separators
                final formattedGiaTri =
                    NumberFormat('#,###').format(voucher.giaTriKhuyenMai);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomPaint(
                    painter: TicketPainter(), // Draws border
                    child: ClipPath(
                      clipper: TicketClipper(), // Clips shape
                      child: Card(
                        color: isEligible
                            ? Colors.white
                            : Colors.grey[300], // Color based on eligibility
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher.tenKhuyenMai,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color:
                                      isEligible ? Colors.black : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                voucher.moTa,
                                style: TextStyle(
                                    color: isEligible
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.local_offer,
                                              color: isEligible
                                                  ? const Color.fromRGBO(
                                                      41, 87, 35, 1)
                                                  : Colors.grey),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            'Giảm ngay $formattedGiaTriđ', // Use formattedGiaTri here
                                            style: TextStyle(
                                                color: isEligible
                                                    ? Colors.black
                                                    : Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Áp dụng tới: ${DateFormat('dd/MM/yyyy').format(voucher.ngayKetThuc)}',
                                        style: TextStyle(
                                          color: isEligible
                                              ? Colors.grey
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isEligible
                                        ? const Color.fromRGBO(41, 87, 35, 1)
                                        : Colors.grey,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                  ),
                                  onPressed: isEligible
                                      ? () {
                                          widget.onPromotionSelected(
                                              voucher); // Pass the entire voucher object
                                          Navigator.pop(
                                              context); // Close the bottom sheet after selecting
                                        }
                                      : null,
                                  child: const Text(
                                    'Sử dụng ngay',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// CustomClipper for Ticket shape
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 20.0;
    const double notchRadius = 22.0;
    final path = Path();

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    path.lineTo(size.width, size.height / 2 - notchRadius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.lineTo(0, size.height / 2 + notchRadius);
    path.arcToPoint(
      Offset(0, size.height / 2 - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double notchRadius = 22.0;
    const double strokeWidth = 3.0;

    final adjustedSize =
        Size(size.width - strokeWidth, size.height - strokeWidth);

    canvas.translate(strokeWidth / 2, strokeWidth / 2);

    final fillPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final path = TicketClipper().getClip(adjustedSize);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
