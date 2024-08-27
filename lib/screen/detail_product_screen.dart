// ignore_for_file: prefer_const_constructors
import 'package:carousel_slider/carousel_slider.dart';
import 'package:don_ganh_app/api_services/variant_api_service.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/models/variant_model.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class DetailProductScreen extends StatefulWidget {
  final ProductModel product;
  const DetailProductScreen({super.key, required this.product});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  late Future<List<VariantModel>> variantModel;

  @override
  void initState() {
    variantModel = VariantApiService().getVariant();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
            child: Container(
              child: ImageIcon(
                AssetImage('lib/assets/arrow_back.png'), // Hình ảnh logo
                size: 49, // Kích thước hình ảnh
              ),
            ),
          ),
        ),
        title: Text('Chi tiết sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 250,
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
                            image: NetworkImage(widget.product.imageProduct),
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
                      bottom: 10,
                      child: Container(
                        height: 60,
                        width: 270,
                        decoration: BoxDecoration(
                          color:
                              Color.fromRGBO(217, 217, 217, 1).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.product.ImgBoSung.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 50,
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          widget.product.ImgBoSung[index].url),
                                      fit: BoxFit.cover),
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
                        print(widget.product.id);
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 700,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
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
                                        Text(
                                          '${widget.product.donGiaBan} đ/kg',
                                          style: TextStyle(fontSize: 16),
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
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child:
                                                Text('Lỗi: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data == null ||
                                          snapshot.data!.isEmpty) {
                                        return Center(
                                            child:
                                                Text('Không tìm thấy dữ liệu'));
                                      }

                                      List<VariantModel> variant =
                                          snapshot.data!;
                                      return Expanded(
                                        child: GridView.builder(
                                          padding: EdgeInsets.all(20),
                                          gridDelegate:
                                              SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 120,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                          ),
                                          itemCount: variant.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                print("");
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 1),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: variant[index]
                                                      .ketHopThuocTinh
                                                      .map((item) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                          '${item.giaTriThuocTinh.GiaTri}'),
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
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: (){}, 
                                        child: Text('Mua Ngay'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size.fromHeight(60),
                                          backgroundColor: Color.fromRGBO(41, 87, 35, 1),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Color.fromRGBO(41, 87, 35, 1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Container(
                                width: 60,
                                child: Icon(
                                  Icons.shopping_cart,
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
                              child: Container(
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

              Padding(
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
            ],
          ),
        ),
      ),
    );
  }
}
