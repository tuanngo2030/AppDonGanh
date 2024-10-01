// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
        title: Text('Tìm kiếm'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset("lib/assets/ic_search.png"),
                    ),
                    hintText: "Tìm kiếm sản phẩm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ListTile(
                leading: Text(
                  "Lịch sử",
                  style: TextStyle(
                    color: Color.fromRGBO(59, 99, 53, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
                trailing: Text(
                  "Xóa",
                   style: TextStyle(
                    color: Color.fromRGBO(248, 158, 25, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),

            Divider(thickness: 2),

            Container(
              height: 500,
              width: 500,
              child: ListView(
                children: [
                  ListTile(
                    title: Text("Tên sản phẩm1"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                   ListTile(
                    title: Text("Tên sản phẩm2"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),

                  ),
                   Divider(thickness: 1),
                   ListTile(
                    title: Text("Tên sản phẩm3"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),

                  ),
                   Divider(thickness: 1),
                   ListTile(
                    title: Text("Tên sản phẩm4"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),

                  ),
                   Divider(thickness: 1),
                    ListTile(
                    title: Text("Tên sản phẩm5"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                    ListTile(
                    title: Text("Tên sản phẩm6"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                    ListTile(
                    title: Text("Tên sản phẩm7"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                    ListTile(
                    title: Text("Tên sản phẩm8"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                    ListTile(
                    title: Text("Tên sản phẩm9"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                    ListTile(
                    title: Text("Tên sản phẩm10"),
                    trailing: Icon(Icons.cancel_outlined, color: Color.fromRGBO(59, 99, 53, 1), size: 30,),
                  ),
                   Divider(thickness: 1),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
