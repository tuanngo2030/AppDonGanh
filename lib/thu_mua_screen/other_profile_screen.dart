import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:don_ganh_app/thu_mua_screen/chat_screen_thuMua.dart';
import 'package:don_ganh_app/widget/postItem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:don_ganh_app/api_services/follow_api_service.dart';
import 'package:don_ganh_app/api_services/blog_api_service.dart';
import 'package:don_ganh_app/models/blog_model.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'dart:convert';

class O extends StatefulWidget {
  final NguoiDung nguoiDung;
  const O({super.key, required this.nguoiDung});

  @override
  State<O> createState() => _OState();
}

class _OState extends State<O> {
  final PageController _pageController = PageController();
  final FollowApiService _followApiService = FollowApiService();
  int _currentPage = 0;
  bool _isFollowing = false;
  String? userId;

  bool _isLoading = false;
  String? token;

  Future<List<BlogModel>>? _userBlogs;
  Future<List<Map<String, dynamic>>>? _userProducts;

  @override
  void initState() {
    super.initState();
    _initializeFollowStatus();
    _loadUserBlogs();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  void _onChat() async {
    setState(() {
      _isLoading = true; // Start loading state
    });

    final ChatApiService apiService = ChatApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('token');

    if (userId != null && token != null) {
      // Ensure userId and token are not null
      try {
        print('User ID: $userId');
        print('Token: $token');

        String receiverId = widget.nguoiDung.id!;
        final response =
            await apiService.createConversation(userId!, receiverId);

        if (response != null && response['_id'] != null) {
          String conversationId = response['_id'];
          bool isCurrentUserSender =
              (receiverId == response['sender_id']['_id']);

          print('conversationId: $conversationId');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenThumua(
                token: token!,
                title: conversationId,
                userId: userId!,
                conversationId: conversationId,
                receiverData: isCurrentUserSender
                    ? response['sender_id'] ??
                        {} // Nếu là sender, hiển thị receiver
                    : response['receiver_id'] ??
                        {}, // Nếu không, hiển thị sender
              ),
            ),
          );
        } else {
          _showSnackBar('Không thể tạo cuộc trò chuyện.');
        }
      } catch (e) {
        _showSnackBar('Đã xảy ra lỗi: $e');
      }
    } else {
      _showSnackBar('User ID hoặc token không có sẵn.');
    }

    setState(() {
      _isLoading = false; // End loading state
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadUserProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    String SetuserId = widget.nguoiDung.id!;
    final response = await UserApiService().fetchUserData(SetuserId, userId!);
    if (mounted) {
      setState(() {
        final sanPhamData = response['sanPham']['list'];
        if (sanPhamData is List) {
          _userProducts =
              Future(() => List<Map<String, dynamic>>.from(sanPhamData));
        } else if (sanPhamData is Map) {
          _userProducts = Future(() => [sanPhamData as Map<String, dynamic>]);
        } else {
          _userProducts = Future.value([]);
        }
      });
    }
  }

  Future<void> _initializeFollowStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    List<String>? followingList = prefs.getStringList('following');

    if (followingList != null && followingList.contains(widget.nguoiDung.id)) {
      setState(() {
        _isFollowing = true;
      });
    }
  }

  Future<void> _loadUserBlogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    String SetuserId = widget.nguoiDung.id!;

    try {
      final response = await UserApiService().fetchUserData(SetuserId, userId!);

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          final blogData =
              response['baiViet']['list']; // Adjust based on actual JSON key
          if (blogData is List) {
            _userBlogs = Future(() =>
                blogData.map((json) => BlogModel.fromJson(json)).toList());
          } else {
            _userBlogs = Future.value([]);
          }
        });
      }
    } catch (e) {
      // Handle any exceptions, such as network errors
      print('Error loading user blogs: $e');
    }
  }

  Future<void> _toggleFollow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? followingList = prefs.getStringList('following') ?? [];

    String action = _isFollowing ? 'unfollow' : 'follow';
    _followApiService.toggleFollowUser(
      userId: userId!,
      targetId: widget.nguoiDung.id!,
      action: action,
    );

    setState(() {
      _isFollowing = !_isFollowing;
    });

    if (_isFollowing) {
      followingList.add(widget.nguoiDung.id!);
    } else {
      followingList.remove(widget.nguoiDung.id!);
    }
    await prefs.setStringList('following', followingList);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text('Trang cá nhân'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        border: const Border.fromBorderSide(
                          BorderSide(
                              color: Color.fromRGBO(47, 88, 42, 1), width: 2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: widget.nguoiDung.anhDaiDien != null
                            ? Image.network(
                                widget.nguoiDung.anhDaiDien!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // When the image fails to load, display a default image or icon
                                  return Image.asset(
                                    'lib/assets/avt2.jpg', // Provide your fallback image path here
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    widget.nguoiDung.tenNguoiDung!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color.fromRGBO(47, 88, 42, 1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? Colors.red
                                : const Color.fromRGBO(47, 88, 42, 1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isFollowing
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                _isFollowing ? 'Bỏ theo dõi' : 'Theo dõi',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onChat(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            'Nhắn tin',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 70, right: 70),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(0);
                        },
                        child: Text(
                          'Bài viết',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _currentPage == 0
                                ? const Color.fromRGBO(47, 88, 42, 1)
                                : Colors.black,
                            decoration: _currentPage == 0
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(1);
                          if (_userProducts == null) _loadUserProducts();
                        },
                        child: Text(
                          'Sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _currentPage == 1
                                ? const Color.fromRGBO(47, 88, 42, 1)
                                : Colors.black,
                            decoration: _currentPage == 1
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 530,
                  width: 500,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      FutureBuilder<List<BlogModel>>(
                        future: _userBlogs,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            final blogs = snapshot.data!;
                            return ListView.builder(
                              itemCount: blogs.length,
                              itemBuilder: (context, index) {
                                return PostItem(post: blogs[index]);
                              },
                            );
                          } else {
                            return const Center(
                                child: Text('No data available'));
                          }
                        },
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _userProducts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show loading indicator when waiting for the API response
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            // Display error if the API call fails
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final products = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: GridView.builder(
                                shrinkWrap: true,
                                // physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         DetailProductScreen(product: product, isfavorited: product['isFavorited']),
                                      //   ),
                                      // );
                                    },
                                    child: Column(
                                      children: [
                                        Flexible(
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                height: 150,
                                                width: 200,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    product['HinhSanPham'] ??
                                                        '',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        exception, stackTrace) {
                                                      return Image.asset(
                                                          'lib/assets/avt2.jpg',
                                                          fit: BoxFit.cover);
                                                    },
                                                  ),
                                                ),
                                              ),
                                              // Discount Badge
                                              Positioned(
                                                top: 15,
                                                child: Container(
                                                  width: 50,
                                                  height: 25,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                    color: Color.fromRGBO(
                                                        142, 198, 65, 1),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "- ${product['PhanTramGiamGia']}%",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Favorite Icon
                                              Positioned(
                                                top: 10,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      // product['isFavorited'] = !product['isFavorited'];
                                                    });
                                                    // _addToFavorites(context, product['IDSanPham']);
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          // ? Colors.red
                                                          const Color.fromRGBO(
                                                              241, 247, 234, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        // product['isFavorited']
                                                        // ? Icons.favorite
                                                        Icons
                                                            .favorite_border_outlined,
                                                        color:
                                                            // product['isFavorited']
                                                            // ? Colors.white
                                                            Color.fromRGBO(142,
                                                                198, 65, 1),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Product Name and Rating
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product['TenSanPham'] ??
                                                      'No Name',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color.fromRGBO(
                                                        41, 87, 35, 1),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Row(
                                                children: [
                                                  Icon(Icons.star,
                                                      color: Colors.amber),
                                                  Text("5"),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Price Display
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 7.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(product['DonGiaBan'])} đ/kg',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 'Mua Ngay' Button
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              print('add to cart');
                                            },
                                            child: Container(
                                              height: 35,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border:
                                                    const Border.fromBorderSide(
                                                  BorderSide(
                                                      color: Colors.black,
                                                      width: 1.5),
                                                ),
                                                color: const Color.fromRGBO(
                                                    41, 87, 35, 1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Expanded(
                                                    flex: 2,
                                                    child: Icon(
                                                      Icons
                                                          .shopping_cart_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Container(
                                                    height: double.infinity,
                                                    width: 1,
                                                    color: Colors.black,
                                                  ),
                                                  const Expanded(
                                                    flex: 3,
                                                    child: Center(
                                                      child: Text(
                                                        'Mua Ngay',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return const Center(
                                child: Text(
                                    'Chưa có sản phẩm nào')); // No products available
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
