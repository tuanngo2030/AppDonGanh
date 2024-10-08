import 'package:don_ganh_app/api_services/product_api_service.dart';
import 'package:don_ganh_app/models/cart_model.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class PayScreen1 extends StatefulWidget {
  const PayScreen1({super.key});

  @override
  State<PayScreen1> createState() => _PayScreen1State();
}

class _PayScreen1State extends State<PayScreen1> {

  String groupValue = "Anh";
  String groupValueRequest = "Giao hàng tại nhà";

    Future<ProductModel> fetchProduct(String productID) async {
    return await ProductApiService().getProductByID(productID);
  }
  @override
  Widget build(BuildContext context) {
         final List<ChiTietGioHang> selectedItems =
        ModalRoute.of(context)!.settings.arguments as List<ChiTietGioHang>;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            //List product will pay
           Container(
              height: 200,
              width: double.infinity,
              child:  ListView.builder(
                    itemCount: selectedItems!.length,
                    itemBuilder: (context, index) {
                      final item = selectedItems![index];

                      return FutureBuilder<ProductModel>(
                        future: fetchProduct(item.variantModel.idProduct),
                        builder: (context, productSnapshot) {
                          if (!productSnapshot.hasData) {
                            return CircularProgressIndicator(); // Show a loading indicator while fetching product details
                          }

                          ProductModel product = productSnapshot.data!;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                product.imageProduct),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${product.nameProduct}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: item
                                                .variantModel.ketHopThuocTinh
                                                .map((thuocTinh) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Text(
                                                  '${thuocTinh.giaTriThuocTinh.GiaTri}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          SizedBox(height: 4),
                                          Text('Đơn giá: ${item.donGia} đ/kg'),
                                          SizedBox(height: 4),
                                          Container(
                                            width: 120,
                                            height: 30,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${item.soLuong}",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
           ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(color: Color.fromARGB(255, 204, 202, 202)),
              )),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin khách hàng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '*Những thông tin ở đây là thông tin mặc định của quý khách và những thay đổi ở đây sẽ không được lưu.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                    //Radio Buttons
                    Row(
                      children: [
                        Radio(
                            activeColor: Color.fromRGBO(59, 99, 53, 1),
                            value: "Anh",
                            groupValue: groupValue,
                            onChanged: (value) {
                              setState(() {
                                groupValue = value!;
                              });
                            }),
                        Text(
                          "Anh",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(width: 20),
                        Radio(
                            activeColor: Color.fromRGBO(59, 99, 53, 1),
                            value: "Chị",
                            groupValue: groupValue,
                            onChanged: (value) {
                              setState(() {
                                groupValue = value!;
                              });
                            }),
                        Text(
                          "Chị",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),

                    //TexField name and phone number
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Họ và tên',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Số điện thoại',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Yêu cầu nhận hàng",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),

                    //RadioButton Yêu cầu nhận hàng
                    Row(
                      children: [
                        Radio(
                            activeColor: Color.fromRGBO(59, 99, 53, 1),
                            value: "Giao hàng tại nhà",
                            groupValue: groupValueRequest,
                            onChanged: (value) {
                              setState(() {
                                groupValueRequest = value!;
                              });
                            }),
                        Text(
                          "Giao hàng tại nhà",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(width: 20),
                        Radio(
                            activeColor: Color.fromRGBO(59, 99, 53, 1),
                            value: "Nhận tại cửa hàng",
                            groupValue: groupValueRequest,
                            onChanged: (value) {
                              setState(() {
                                groupValueRequest = value!;
                              });
                            }),
                        Text(
                          "Nhận tại cửa hàng",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),

                    //address
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                              ),

                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Tỉnh/Thành Phố"
                                )
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                              ),

                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Quận/Huyện"
                                )
                              ),
                            ),
                          ),
                        ),
                      ]
                    ),

                     Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                              ),

                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Phường/Xã"
                                )
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                              ),

                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Đường/Thôn xóm"
                                )
                              ),
                            ),
                          ),
                        ),
                      ]
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Ghi chú cho người bán",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        maxLines: 6,
                        minLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: 'Gõ vào đây',
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
              ),
            )
          ],
        ),
      ),
    );
  }
}
