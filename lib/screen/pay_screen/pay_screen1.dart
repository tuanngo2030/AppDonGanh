import 'package:flutter/material.dart';
class PayScreen1 extends StatefulWidget {
  const PayScreen1({super.key});

  @override
  State<PayScreen1> createState() => _PayScreen1State();
}

class _PayScreen1State extends State<PayScreen1> {
   String groupValue = "Anh";
  String groupValueRequest = "Giao hàng tại nhà";
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
              //List product will pay
              // ----------------------------------------------------------------
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '*Những thông tin ở đây là thông tin mặc định của quý khách và những thay đổi ở đây sẽ không được lưu.',
                        style: TextStyle(fontSize: 12),
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
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                child: SizedBox(
                  width:
                      double.infinity, 
                  height: 50, 
                ),
              )
          ],
        ),
      ),
    );
  }
}