// import 'package:flutter/material.dart';


// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _Home();
// }
// class _Home extends State<Home> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           'Cửa hàng',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {},
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.shopping_cart, color: Colors.black),
//             onPressed: () {},
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: Stack(
//               children: [
//                 Icon(Icons.notifications, color: Colors.black),
//                 Positioned(
//                   right: 0,
//                   child: Container(
//                     padding: EdgeInsets.all(1),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     constraints: BoxConstraints(
//                       minWidth: 12,
//                       minHeight: 12,
//                     ),
//                     child: Text(
//                       '0',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 8,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 hintText: 'Tìm kiếm sản phẩm',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 CategoryButton(icon: Icons.agriculture, label: 'Nông sản'),
//                 CategoryButton(icon: Icons.pets, label: 'Chăn nuôi'),
//                 CategoryButton(icon: Icons.local_cafe, label: 'Cafe & tiểu'),
//                 CategoryButton(icon: Icons.spa, label: 'Rau củ'),
//                 CategoryButton(icon: Icons.local_florist, label: 'Trái cây'),
//               ],
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.7,
//                 ),
//                 itemBuilder: (context, index) {
//                   return ProductCard();
//                 },
//                 itemCount: 4,
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         selectedItemColor: Colors.green,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
//         ],
//       ),
//     );
//   }
// }

// class CategoryButton extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   CategoryButton({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Icon(icon, size: 32, color: Colors.green),
//         Text(label, style: TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }

// class ProductCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Image.network(
//                 'https://via.placeholder.com/150',
//                 height: 120,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Icon(Icons.favorite_border, color: Colors.white),
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Text('Khoai tây', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text('40.000 đ/kg', style: TextStyle(color: Colors.green)),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '60.000 đ/kg',
//                       style: TextStyle(
//                         decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                     Text(
//                       '-10%',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {},
//             child: Text('Mua ngay'),
//           ),
//         ],
//       ),
//     );
//   }
// }
