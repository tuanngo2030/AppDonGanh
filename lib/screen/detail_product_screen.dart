// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/api_services/chat_api_service.dart';
import 'package:don_ganh_app/api_services/review_api_service.dart';
import 'package:don_ganh_app/api_services/variant_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/models/review_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';
import 'package:don_ganh_app/screen/all_review.dart';
import 'package:don_ganh_app/screen/chat_screen.dart';
import 'package:don_ganh_app/screen/order_review_screen.dart';
import 'package:don_ganh_app/widget/FullImageDialog.dart';
import 'package:don_ganh_app/widget/badge_widget.dart';
import 'package:don_ganh_app/widget/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

class DetailProductScreen extends StatefulWidget {
  final ProductModel product;
  final bool isfavorited;
  const DetailProductScreen(
      {super.key, required this.product, required this.isfavorited});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  int donGia = 0;
  String selectedVariantId = '';
  int quantity = 1;
  int soluong = 0;
  late Future<List<VariantModel>> variantModel;
  final bool _showResponses = false;
  int _totalReviews = 0;

  String mainImageUrl = '';
  List<String> supplementaryImages = [];
  late Future<List<DanhGia>> _reviewsFuture;
  List<DanhGia> _reviews = [];

  bool isButtonHidden = false;
  Timer? _timer;
  String? userId;
  String? token;

  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();

  bool _isLoading = false;
  GlobalKey<BadgeWidgetState> badgeKey = GlobalKey<BadgeWidgetState>();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeProductData();
    _quantityController.text = quantity.toString();
    // donGia = widget.product.donGiaBan;
    // soluong = widget.product.soLuongHienTai;
    // mainImageUrl = widget.product.imageProduct;
    // supplementaryImages =
    //     widget.product.ImgBoSung.map((img) => img.url).toList();
    // variantModel = VariantApiService().getVariant(widget.product.id);
    _startHideTimer();
    _fetchCartItemCount();
  }

   void _fetchCartItemCount() async {
    try {
      List<CartModel> carts = await CartApiService().getGioHangByUserId();
      int itemCount = 0;
      for (var cart in carts) {
        for (var item in cart.mergedCart) {
          for (var product in item.sanPhamList) {
            itemCount += product.chiTietGioHangs.length;
          }
        }
      }
      setState(() {
        _cartItemCount = itemCount;
      });
    } catch (e) {
      print("Lỗi khi lấy giỏ hàng: $e");
    }
  }


  void _initializeProductData() {
    donGia = widget.product.donGiaBan;
    soluong = widget.product.soLuongHienTai;
    mainImageUrl = widget.product.imageProduct;
    supplementaryImages =
        widget.product.ImgBoSung.map((img) => img.url).toList();
    variantModel = VariantApiService().getVariant(widget.product.id);
    _fetchReviews(); // Fetch reviews once here
  }

  Future<void> _fetchReviews() async {
    // Fetch reviews once and don't call setState in every render cycle
    _reviewsFuture =
        ReviewApiService().getReviewsByProductId(widget.product.id);
    final reviews = await _reviewsFuture;
    if (mounted) {
      // Ensure widget is still mounted before calling setState
      setState(() {
        _reviews = reviews;
        _totalReviews = reviews.length; // Update the total reviews count
      });
    }
  }

  void plusQuantity() {
    setState(() {
      if (quantity < soluong) {
        quantity++;
        _quantityController.text = quantity.toString(); // Update the TextField
      }
    });
  }

  void minusQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
        _quantityController.text = quantity.toString(); // Update the TextField
      }
    });
  }

  void _swapImage(int index) {
    setState(() {
      // Swap images without triggering any re-fetch of data
      String selectedImage = supplementaryImages[index];
      String oldMainImage = mainImageUrl;
      mainImageUrl = selectedImage;
      supplementaryImages[index] = oldMainImage;
    });
  }

  Future<void> addToCart(
      String variantId, int donGia, VoidCallback? refreshBadge) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
          child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(41, 87, 35, 1)),
      )),
    );

    try {
      await CartApiService().addToCart(userId, variantId, quantity, donGia);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm vào giỏ hàng thành công')),
      );
    } catch (e) {
      _fetchCartItemCount();
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm vào giỏ hàng thành công')),
      );

      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop(); // Close the loading dialog
    }
  }

  void _showFullImage(String imageUrl) {
    int initialIndex = supplementaryImages.indexOf(imageUrl);

    if (initialIndex == -1) {
      if (imageUrl == mainImageUrl) {
        initialIndex = 0;
      } else {
        return;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FullImageDialog(
          images: [
            mainImageUrl,
            ...supplementaryImages
          ], // Kết hợp hình chính và hình bổ sung
          initialIndex: initialIndex, // Chỉ số hình ảnh hiện tại
        );
      },
    );
  }

  // Bắt đầu bộ đếm để ẩn nút sau 5 giây
  void _startHideTimer() {
    _timer?.cancel(); // Hủy bộ đếm hiện tại nếu có
    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        isButtonHidden = true; // Ẩn nút
      });
    });
  }

  // Xử lý khi nút được nhấn
  void _onButtonPressed() {
    setState(() {
      isButtonHidden = false; // Hiện nút lại
    });
    _startHideTimer(); // Khởi động lại bộ đếm
  }

  // void _onChat() async {
  //   final ChatApiService apiService = ChatApiService();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   userId = prefs.getString('userId');
  //   token = prefs.getString('token');

  //   if (userId != null) {
  //     try {
  //       // Print user ID for debugging
  //       print('User ID: $userId');
  //       print(token);

  //       // Define the receiver ID for the conversation
  //       String receiverId = '671fa0042871b08206a87749';

  //       // Create a conversation and wait for the response
  //       final response =
  //           await apiService.createConversation(userId!, receiverId);

  //       if (response != null && response['_id'] != null) {
  //         String conversationId =
  //             response['_id']; // Retrieve the conversation ID from response

  //         print('conversationId: $conversationId');

  //         // Navigate to the ChatScreen with the new conversationId
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ChatScreen(
  //               token: token!,
  //               title: conversationId,
  //               userId: userId!, // Send userId to ChatScreen
  //               conversationId: conversationId,
  //               receiverData:
  //                   response['receiver_id'], // Pass receiver data if needed
  //               productModel: widget.product,
  //             ),
  //           ),
  //         );
  //       } else {
  //         _showSnackBar('Không thể tạo cuộc trò chuyện.');
  //       }
  //     } catch (e) {
  //       _showSnackBar('Đã xảy ra lỗi: $e');
  //     }
  //   }
  // }
  void _onChat(String receiverId) async {
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
              builder: (context) => ChatScreen(
                token: token!,
                title: conversationId,
                userId: userId!,
                conversationId: conversationId,
                receiverData: isCurrentUserSender
                    ? response['sender_id'] ??
                        {} // Nếu là sender, hiển thị receiver
                    : response['receiver_id'] ??
                        {}, // Nếu không, hiển thị sender
                productModel: widget.product,
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

  void updateQuantity() {
    setState(() {
      quantity = int.tryParse(_quantityController.text) ??
          1; // Update quantity based on input
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    _timer?.cancel(); // Hủy bộ đếm khi màn hình bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              child: ImageIcon(
                AssetImage('lib/assets/arrow_back.png'),
                size: 49,
              ),
            ),
          ),
        ),
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(
              color: Color.fromRGBO(41, 87, 35, 1),
              fontWeight: FontWeight.bold),
        ),
        actions: [
          
          Padding(
              padding: const EdgeInsets.only(right: 15),
              child:  badges.Badge(
      badgeContent: Text(
        _cartItemCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      badgeStyle: const badges.BadgeStyle(
        badgeColor: Color.fromRGBO(255, 0, 0, 1),
        borderSide: BorderSide(color: Colors.white),
        padding: EdgeInsets.all(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/cart_screen');
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color.fromRGBO(41, 87, 35, 1),
          ),
          child: const Icon(
            Icons.shopping_bag,
            color: Colors.white,
          ),
        ),
      ),
    ))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Hiển thị hình ảnh lớn và cho phép zoom
                      _showFullImage(mainImageUrl);
                    },
                    child: SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                image: DecorationImage(
                                  image: NetworkImage(mainImageUrl),
                                  fit: BoxFit.cover,
                                )),
                          ),
                          Positioned(
                            top: 30,
                            left: 0,
                            child: Container(
                              alignment: Alignment.center,
                              height: 25,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20)),
                                color: Colors.green,
                              ),
                              child: Text(
                                '-${widget.product.phanTramGiamGia}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                print("Add to favorites");
                                // You can toggle the isfavorited value here if needed.
                                // For now, it is not updating because it is passed as a parameter.
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: widget.isfavorited
                                      ? Colors.red
                                      : const Color.fromRGBO(241, 247, 234, 1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Icon(
                                    // Check if the product is favorited and set the icon color accordingly
                                    widget.isfavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border_outlined,
                                    color: widget.isfavorited
                                        ? Colors.white
                                        : const Color.fromRGBO(142, 198, 65, 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Container(
                              height: 60,
                              width: 270,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(217, 217, 217, 1)
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: supplementaryImages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Chỉ thay đổi hình ảnh chính
                                        _swapImage(index);
                                      },
                                      child: Container(
                                        width: 50,
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: NetworkImage(supplementaryImages[
                                                index]), // Hiển thị hình ảnh nhỏ
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(27),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.nameProduct,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color.fromRGBO(41, 87, 35, 1),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        //rate
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              Text("5")
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 27, right: 27),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(widget.product.donGiaBan)} đ/kg',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              quantity = 1;
                              _quantityController.text = quantity.toString();
                            });
                            print(widget.product.id);
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setModalState) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                      top: 16.0,
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom, // Đẩy theo bàn phím
                                    ),
                                    child: SizedBox(
                                      height: 500,
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    width: 1),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Container(
                                                    height: 100,
                                                    width: 100,
                                                    margin: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            widget.product
                                                                .imageProduct),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(donGia)} đ/kg',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      'Kho: $soluong sản phẩm',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          FutureBuilder(
                                            future: variantModel,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Lỗi: ${snapshot.error}'));
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data == null ||
                                                  snapshot.data!.isEmpty) {
                                                return Center(
                                                    child: Text(
                                                        'Không tìm thấy dữ liệu'));
                                              }

                                              List<VariantModel> variant =
                                                  snapshot.data!;
                                              return Expanded(
                                                child: GridView.builder(
                                                  padding: EdgeInsets.all(20),
                                                  gridDelegate:
                                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 100,
                                                    mainAxisSpacing: 10,
                                                    crossAxisSpacing: 30,
                                                  ),
                                                  itemCount: variant.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setModalState(() {
                                                          selectedVariantId =
                                                              variant[index].id;
                                                          donGia =
                                                              variant[index]
                                                                  .gia;
                                                          soluong =
                                                              variant[index]
                                                                  .soLuong;
                                                          print(
                                                              '$selectedVariantId $donGia');
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 1),
                                                          color: selectedVariantId ==
                                                                  variant[index]
                                                                      .id
                                                              ? Colors.green
                                                              : Colors.white,
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: variant[
                                                                  index]
                                                              .ketHopThuocTinh
                                                              .map((item) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(item
                                                                  .giaTriThuocTinh
                                                                  .GiaTri),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: SizedBox(
                                              height: 50,
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: Text("Số lượng")),
                                                  SizedBox(width: 8),
                                                  SizedBox(
                                                    width: 150,
                                                    height: 30,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setModalState(
                                                                    () {
                                                                  if (int.parse(
                                                                          _quantityController
                                                                              .text) >
                                                                      1) {
                                                                    minusQuantity();
                                                                  }
                                                                });
                                                              },
                                                              icon: Icon(
                                                                  Icons.remove),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    _quantityFocusNode);
                                                          },
                                                          child: SizedBox(
                                                            width: 50,
                                                            child: TextField(
                                                              controller:
                                                                  _quantityController,
                                                              focusNode:
                                                                  _quantityFocusNode,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        bottom:
                                                                            17.0),
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                    .isNotEmpty) {
                                                                  int?
                                                                      quantity =
                                                                      int.tryParse(
                                                                          value);
                                                                  if (quantity ==
                                                                          null ||
                                                                      quantity <
                                                                          1 ||
                                                                      quantity >
                                                                          10) {
                                                                    _quantityController
                                                                        .text = (quantity !=
                                                                                null &&
                                                                            quantity >
                                                                                10)
                                                                        ? '10'
                                                                        : '1';
                                                                    _quantityController
                                                                            .selection =
                                                                        TextSelection.fromPosition(TextPosition(
                                                                            offset:
                                                                                _quantityController.text.length));
                                                                  }
                                                                }
                                                              },
                                                              onSubmitted:
                                                                  (value) {
                                                                updateQuantity();
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setModalState(
                                                                    () {
                                                                  if (int.parse(
                                                                          _quantityController
                                                                              .text) <
                                                                      10) {
                                                                    plusQuantity();
                                                                  }
                                                                });
                                                              },
                                                              icon: Icon(
                                                                  Icons.add),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Center(
                                              child: ElevatedButton(
                                                onPressed: selectedVariantId
                                                            .isEmpty ||
                                                        _isLoading
                                                    ? null
                                                    : () async {
                                                        setState(() {
                                                          quantity = int.tryParse(
                                                                  _quantityController
                                                                      .text) ??
                                                              1; // Chuyển đổi giá trị từ TextEditingController
                                                          _isLoading =
                                                              true; // Bắt đầu trạng thái loading khi bấm nút
                                                        });

                                                        await addToCart(
                                                            selectedVariantId,
                                                            donGia, () {
                                                          badgeKey.currentState
                                                              ?.refreshCartItemCount();
                                                        });

                                                        setState(() {
                                                          _isLoading =
                                                              false; // Kết thúc trạng thái loading sau khi thêm vào giỏ hàng
                                                        });
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size.fromHeight(60),
                                                  backgroundColor:
                                                      selectedVariantId
                                                                  .isEmpty ||
                                                              _isLoading
                                                          ? Colors.grey
                                                          : const Color
                                                              .fromRGBO(
                                                              41, 87, 35, 1),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                  ),
                                                ),
                                                child: _isLoading
                                                    ? const CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      )
                                                    : const Text(
                                                        'Thêm Vào Giỏ Hàng'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                          child: Container(
                            height: 40,
                            width: 180,
                            decoration: BoxDecoration(
                                border: Border.fromBorderSide(BorderSide(
                                    color: Colors.black, width: 1.5)),
                                color: Color.fromRGBO(41, 87, 35, 1),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 60,
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                    )),
                                Container(
                                  height: double.infinity,
                                  width: 1,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
                                ),
                                Center(
                                  child: SizedBox(
                                    width: 100,
                                    child: Text(
                                      'Mua Ngay',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Chi tiết sản phẩm
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 27.0, left: 27, right: 27, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mô tả',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(41, 87, 35, 1),
                        ),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 27, right: 27),
                      child: ReadMoreText(
                        widget.product.moTa,
                        trimLines: 3,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: "Xem Thêm",
                        trimExpandedText: "Ẩn",
                        moreStyle: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Color.fromRGBO(248, 158, 25, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(248, 158, 25, 1)),
                        lessStyle: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Color.fromRGBO(248, 158, 25, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(248, 158, 25, 1)),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 27),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 27),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đánh giá sản phẩm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(41, 87, 35, 1),
                                      ),
                                    ),
                                    FutureBuilder<List<DanhGia>>(
                                      future: _reviewsFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text(
                                            'Đang tải đánh giá...',
                                            style: TextStyle(fontSize: 16),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                            'Lỗi: ${snapshot.error}',
                                            style: TextStyle(fontSize: 16),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Text(
                                            'Chưa có lượt đánh giá nào',
                                            style: TextStyle(fontSize: 16),
                                          );
                                        }

                                        // Tính tổng số sao và trung bình sao
                                        final reviews = snapshot.data!;
                                        _totalReviews = reviews.length;
                                        double totalStars = reviews.fold(
                                            0.0,
                                            (sum, review) =>
                                                sum + review.xepHang);
                                        double averageStars =
                                            totalStars / _totalReviews;

                                        return Text(
                                          'Đánh giá: ${averageStars.toStringAsFixed(1)} ($_totalReviews lượt đánh giá)',
                                          style: TextStyle(fontSize: 16),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => OrderReviewScreen(
                                //           title: 'sản phẩm',
                                //           id: widget.product.id,
                                //         ),
                                //       ),
                                //     ).then((_) {
                                //       _fetchReviews();
                                //     });
                                //   },
                                //   child: Text(
                                //     'Đánh giá',
                                //     style: TextStyle(
                                //       fontWeight: FontWeight.w600,
                                //       color: Color.fromRGBO(41, 87, 35, 1),
                                //       decoration: TextDecoration.underline,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1, color: Colors.grey),
                          FutureBuilder<List<DanhGia>>(
                            future:
                                _reviewsFuture, // Sử dụng biến _reviewsFuture đã được khởi tạo
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('Chưa có lượt đánh giá nào'));
                              }

                              // Lấy 2 đánh giá gần nhất
                              final reviews = snapshot.data!;
                              final recentReviews =
                                  reviews.reversed.take(2).toList();
                              _totalReviews = reviews.length;

                              // Hiển thị danh sách đánh giá gần nhất
                              return SizedBox(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: recentReviews.length,
                                  itemBuilder: (context, index) {
                                    final review = recentReviews[index];
                                    return ReviewItem(
                                      review: review,
                                      onDelete:
                                          _fetchReviews, // Nếu cần thiết, bạn có thể gọi lại đánh giá
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllReviewsPage(
                                      productId: widget.product.id),
                                ),
                              ).then((_) {
                                _fetchReviews();
                              });
                            },
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _totalReviews <= 2
                                        ? 'Xem tất cả ($_totalReviews) >'
                                        : 'Xem tất cả (${_totalReviews - 2}) >',
                                    style: TextStyle(
                                        color: Color.fromRGBO(41, 87, 35, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 27),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      widget.product.userId.anhDaiDien !=
                                                  null &&
                                              widget.product.userId.anhDaiDien!
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              widget.product.userId.anhDaiDien!)
                                          : AssetImage('lib/assets/avt2.jpg')
                                              as ImageProvider,
                                ),
                                SizedBox(width: 8),
                                Text(widget.product.userId.tenNguoiDung!),
                              ],
                            ),
                            Align(
                              child: Container(
                                alignment: Alignment.center,
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.fromBorderSide(BorderSide(
                                        width: 1, color: Colors.black))),
                                child: Text('Xem shop'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nút cố định với vị trí thu gọn và mở rộng
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            bottom: 20.0,
            right: isButtonHidden ? -30.0 : 20.0,
            child: GestureDetector(
              onTap: () {
                if (isButtonHidden) {
                  setState(() {
                    isButtonHidden = false;
                  });
                  _startHideTimer();
                } else {
                  _onChat(widget.product.userId.id!);
                }
              },
              child: Opacity(
                opacity: isButtonHidden ? 0.5 : 1.0,
                child: FloatingActionButton(
                  backgroundColor: Color.fromRGBO(59, 99, 53, 1),
                  onPressed: () {
                    if (isButtonHidden) {
                      setState(() {
                        isButtonHidden = false;
                      });
                      _startHideTimer();
                    } else {
                      _onChat(widget.product.userId.id!);
                    }
                  },
                  child: Icon(Icons.message_outlined, color: Colors.white),
                ),
              ),
            ),
          ),

          // Overlay loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
