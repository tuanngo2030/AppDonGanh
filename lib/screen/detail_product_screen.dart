// ignore_for_file: prefer_const_constructors
import 'package:carousel_slider/carousel_slider.dart';
import 'package:don_ganh_app/api_services/cart_api_service.dart';
import 'package:don_ganh_app/api_services/review_api_service.dart';
import 'package:don_ganh_app/api_services/variant_api_service.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/models/review_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';
import 'package:don_ganh_app/screen/all_review.dart';
import 'package:don_ganh_app/screen/order_review_screen.dart';
import 'package:don_ganh_app/widget/FullImageDialog.dart';
import 'package:don_ganh_app/widget/badge_widget.dart';
import 'package:don_ganh_app/widget/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

class DetailProductScreen extends StatefulWidget {
  final ProductModel product;
  const DetailProductScreen({super.key, required this.product});

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

  @override
  void initState() {
    super.initState();
    _initializeProductData();
    // donGia = widget.product.donGiaBan;
    // soluong = widget.product.soLuongHienTai;
    // mainImageUrl = widget.product.imageProduct;
    // supplementaryImages =
    //     widget.product.ImgBoSung.map((img) => img.url).toList();
    // variantModel = VariantApiService().getVariant(widget.product.id);
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
      if (quantity < 10) quantity++;
    });
  }

  void minusQuantity() {
    setState(() {
      if (quantity > 1) quantity--;
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

  Future<void> addToCart(String variantId, int donGia) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }
    try {
      await CartApiService().addToCart(userId, variantId, quantity, donGia);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm vào giỏ hàng thành công')),
      );
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm vào giỏ hàng thành công')),
      );

      Navigator.of(context).pop();
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
        images: [mainImageUrl, ...supplementaryImages], // Kết hợp hình chính và hình bổ sung
        initialIndex: initialIndex,    // Chỉ số hình ảnh hiện tại
      );
    },
  );
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
        title: Text('Chi tiết sản phẩm'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: BadgeWidget(),
          )
        ],
      ),
      body: SingleChildScrollView(
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
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(241, 247, 234, 1),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Center(
                                child: Icon(
                                  Icons.favorite_border_outlined,
                                  color: Color.fromRGBO(142, 198, 65, 1),
                                ),
                              ),
                            ),
                          )),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          height: 60,
                          width: 270,
                          decoration: BoxDecoration(
                            color:
                                Color.fromRGBO(217, 217, 217, 1).withOpacity(0.3),
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
                                      borderRadius: BorderRadius.circular(10),
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
                    Text('${widget.product.donGiaBan} đ/kg',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        )),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          quantity = 1;
                        });
                        print(widget.product.id);
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setModalState) {
                              return SizedBox(
                                height: 500,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              margin: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: NetworkImage(widget
                                                      .product.imageProduct),
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
                                                '$donGia đ/kg',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                'Kho: $soluong sản phẩm',
                                                style: TextStyle(fontSize: 16),
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
                                              maxCrossAxisExtent: 50,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 30,
                                            ),
                                            itemCount: variant.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedVariantId =
                                                        variant[index].id;
                                                    donGia = variant[index].gia;
                                                    soluong =
                                                        variant[index].soLuong;
                                                    print(
                                                        '$selectedVariantId $donGia');
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 1),
                                                    color: selectedVariantId ==
                                                            variant[index].id
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
                                                    children: variant[index]
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text("Số lượng")),
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
                                                      alignment:
                                                          Alignment.center,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          setModalState(() {
                                                            minusQuantity();
                                                          });
                                                        },
                                                        icon:
                                                            Icon(Icons.remove),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "$quantity",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          setModalState(() {
                                                            plusQuantity();
                                                          });
                                                        },
                                                        icon: Icon(Icons.add),
                                                        padding:
                                                            EdgeInsets.zero,
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
                                          onPressed: selectedVariantId.isEmpty
                                              ? null
                                              : () {
                                                  addToCart(selectedVariantId,
                                                      donGia);
                                                },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size.fromHeight(60),
                                            backgroundColor: selectedVariantId
                                                    .isEmpty
                                                ? Colors.grey
                                                : Color.fromRGBO(41, 87, 35, 1),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                          ),
                                          child: Text('Thêm Vào Giỏ Hàng'),
                                        ),
                                      ),
                                    )
                                  ],
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
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.black, width: 1.5)),
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
                                Text(
                                    'Đánh giá: 4.5 ($_totalReviews lượt đánh giá)'),
                                SizedBox(height: 10),
                              ],
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OrderReviewScreen(
                                                title: 'sản phẩm',
                                                id: widget.product.id,
                                              ))).then((_) {
                                    _fetchReviews();
                                  });
                                },
                                child: Text(
                                  'Đánh giá',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(41, 87, 35, 1),
                                      decoration: TextDecoration.underline),
                                )),
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
                            return Center(child: CircularProgressIndicator());
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
                              builder: (context) =>
                                  AllReviewsPage(productId: widget.product.id),
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
            ],
          ),
        ),
      ),
    );
  }
}
