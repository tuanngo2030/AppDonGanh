import 'dart:convert';
import 'package:don_ganh_app/api_services/bank_api_service.dart';
import 'package:don_ganh_app/api_services/rut_tien_api_service.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/bank_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SoDuScreen extends StatefulWidget {
  const SoDuScreen({super.key});

  @override
  State<SoDuScreen> createState() => _SoDuScreenState();
}

class _SoDuScreenState extends State<SoDuScreen> {
  int? soDu;
  String? name;
  String? userId;

  // TextEditingController variables for other fields
  TextEditingController soTaiKhoanController = TextEditingController();
  TextEditingController soTienController = TextEditingController();
  TextEditingController ghiChuController = TextEditingController();

  // Dropdown-related variables
  List<Bank> danhSachNganHang = [];
  Bank? tenNganHangDaChon; // Lưu trữ Bank thay vì String

  @override
  void initState() {
    super.initState();
    _getSoDu();
    _fetchDanhSachNganHang();
  }

  // Retrieve user data from SharedPreferences
  Future<void> _getSoDu() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedSoDu = prefs.getInt('soTienHienTai');
    String? storedName = prefs.getString('tenNguoiDung');
    String? storedUserId = prefs.getString('userId');
    setState(() {
      soDu = storedSoDu;
      name = storedName;
      userId = storedUserId;
    });
  }

  // Fetch list of banks
  Future<void> _fetchDanhSachNganHang() async {
    try {
      final List<Bank> banks = await BankService.fetchBanks();
      setState(() {
        danhSachNganHang = banks; // danhSachNganHang là List<Bank>
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách ngân hàng')),
      );
    }
  }

  // Format the balance with thousands separators
  String _formatSoDu(int? soDu) {
    if (soDu == null) return 'Loading...';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(soDu)} VNĐ';
  }

  Future<bool> showPasswordConfirmationDialog(
      BuildContext context, String email) async {
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;
     SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Xác nhận mật khẩu'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Nhập mật khẩu'),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, false); // Return `false` when cancelled
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final response = await UserApiService().loginXacMinh(
                      email,
                      passwordController.text,
                      storedUserId!,
                    );
                    setState(() {
                      isLoading = false;
                    });
                    if (response['error'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${response['message']}')),
                      );
                    } else {
                      Navigator.pop(
                          context, true); // Return `true` when success
                    }
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false; // Ensure a `bool` value is always returned
  }

  Future<String?> getEmailFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gmail'); // Replace 'userEmail' with your key
  }

  void _handleWithdraw(BuildContext context) async {
    showModalBottomSheet(
      isScrollControlled: true, // Cho phép điều chỉnh chiều cao theo bàn phím
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Đẩy theo bàn phím
          ),
          child: SingleChildScrollView(
            // Đảm bảo cuộn được khi nội dung vượt quá chiều cao
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Chọn tài khoản',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Bank>(
                  value: tenNganHangDaChon,
                  items: danhSachNganHang
                      .map((bank) => DropdownMenuItem<Bank>(
                            value: bank,
                            child: Row(
                              children: [
                                Image.network(
                                  bank.logo,
                                  height: 50,
                                  width: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(bank.shortName),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (Bank? value) {
                    tenNganHangDaChon = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tên ngân hàng',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Số tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  controller: soTaiKhoanController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Tổng tiền rút',
                    border: OutlineInputBorder(),
                  ),
                  controller: soTienController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                  controller: ghiChuController,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        tenNganHangDaChon = null;
                        soTaiKhoanController.clear();
                        soTienController.clear();
                        ghiChuController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (tenNganHangDaChon == null ||
                            soTaiKhoanController.text.isEmpty ||
                            soTienController.text.isEmpty ||
                            double.tryParse(soTienController.text) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Vui lòng điền đầy đủ thông tin')),
                          );
                          return;
                        }

                        // Retrieve email from SharedPreferences
                        final email = await getEmailFromSharedPreferences();
                        if (email == null || email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Email không tồn tại. Vui lòng đăng nhập lại.')),
                          );
                          return;
                        }

                        // Show password confirmation dialog
                        bool isConfirmed = await showPasswordConfirmationDialog(
                          context,
                          email, // Pass the retrieved email
                        );

                        if (!isConfirmed) {
                          return;
                        }

                        // Proceed with the withdrawal process
                        double enteredSoTien =
                            double.tryParse(soTienController.text) ?? 0;
                        final response =
                            await YeuCauRutTienApi().createYeuCauRutTien(
                          userId: userId ?? '',
                          tenNganHang: tenNganHangDaChon!.shortName,
                          soTaiKhoan: soTaiKhoanController.text,
                          soTien: enteredSoTien,
                          ghiChu: ghiChuController.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${response['message']}')),
                        );

                        // Clear inputs and navigate back
                        tenNganHangDaChon = null;
                        soTaiKhoanController.clear();
                        soTienController.clear();
                        ghiChuController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Xác nhận'),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                                // Withdraw button positioned
                                ElevatedButton(
                                  onPressed: () => _handleWithdraw(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 60, 60, 60),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Rút tiền'),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Add space between text and image
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Positioned image on top of the container
                Positioned(
                  top: 50, // Adjust top position
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
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Dịch vụ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/yeu_cau_rut_screen');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    height: 80,
                    width: 160,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(217, 217, 217, 1)),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.text_snippet_outlined),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Text(
                              'Giao dịch',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushNamed(context, '/doanh_thu_screen');
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.all(8),
              //     child: Container(
              //       height: 80,
              //       width: 160,
              //       alignment: Alignment.centerLeft,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(10),
              //           color: const Color.fromRGBO(217, 217, 217, 1)),
              //       child: const Padding(
              //         padding: EdgeInsets.only(left: 20),
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Icon(Icons.bar_chart_outlined),
              //             Padding(
              //               padding: EdgeInsets.only(
              //                 top: 10,
              //               ),
              //               child: Text(
              //                 'Doanh thu',
              //                 style: TextStyle(
              //                     fontSize: 13, fontWeight: FontWeight.w900),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ],
      ),
    );
  }
}
