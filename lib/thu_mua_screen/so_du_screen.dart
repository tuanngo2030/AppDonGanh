import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package for formatting

class SoDuScreen extends StatefulWidget {
  const SoDuScreen({super.key});

  @override
  State<SoDuScreen> createState() => _SoDuScreenState();
}

class _SoDuScreenState extends State<SoDuScreen> {
  int? soDu;
  String? name;

  @override
  void initState() {
    super.initState();
    _getSoDu(); // Call the function to load the data
  }

  // Retrieve the data from SharedPreferences
  Future<void> _getSoDu() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedSoDu = prefs.getInt('soTienHienTai');
    String? storedName = prefs.getString('tenNguoiDung');
    setState(() {
      soDu = storedSoDu; // Update the state with the retrieved value
      name = storedName; // Update the state with the retrieved value
    });
  }

  // Format the balance with thousands separators
  String _formatSoDu(int? soDu) {
    if (soDu == null) return 'Loading...';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(soDu)} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Số Dư'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Số dư của $name',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity, // Full width
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0), // Optional margin
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 28, 27, 27),
                        Color.fromARGB(
                            255, 60, 60, 60), // Lighter shade for fade
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0), // Match Card border radius
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize.min, // Height adjusts to content
                              children: [
                                const Text(
                                  'Số dư',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatSoDu(
                                      soDu), // Use the formatted balance
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 70),
                              ],
                            ),
                            const Spacer(), // Add space between text and image
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned image on top of the container
                Positioned(
                  top: 30, // Adjust top position
                  right: 10, // Adjust right position
                  child: Opacity(
                    opacity: 0.03, // Set the desired opacity
                    child: Transform.rotate(
                      angle: 30 * 3.1416 / 180, // Rotate 30 degrees in radians
                      child: Container(
                        height: 130, // Set container height
                        width: 130, // Set container width
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'lib/assets/logo_app_png.png'), // Replace with your logo path
                            fit: BoxFit
                                .contain, // Make the image cover the entire container
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
