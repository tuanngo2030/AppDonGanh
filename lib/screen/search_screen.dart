import 'package:don_ganh_app/api_services/search_api_service.dart';
import 'package:don_ganh_app/models/product_model.dart';
import 'package:don_ganh_app/screen/detail_product_screen.dart';
import 'package:don_ganh_app/screen/search_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<ProductModel> sanphams = [];
  List<ProductModel> filteredSanphams = [];
  String searchTerm = "";
  List<String> savedKeywords = [];

  @override
  void initState() {
    super.initState();
    loadSavedKeywords(); // Load saved keywords when the screen initializes
  }

  Future<void> fetchSanPhams(String tenSanPham) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    try {
      final results = await searchSanPham(tenSanPham, userId: userId!, yeuthichId: '67299b5b3318cd90d77a43b6');
      setState(() {
        // Convert each result to ProductModel
        sanphams = results
            .map<ProductModel>((item) => ProductModel.fromJSON(item))
            .toList();
        filteredSanphams = sanphams; // Initialize filtered list
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> navigateToResults() async {
    if (searchTerm.isNotEmpty) {
      await saveKeyword(searchTerm); // Save the keyword before navigating
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(searchTerm: searchTerm),
        ),
      );
    }
  }

  Future<void> loadSavedKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedKeywords = prefs.getStringList('savedKeywords') ?? [];
    });
  }

  Future<void> saveKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    if (!savedKeywords.contains(keyword)) {
      savedKeywords.add(keyword);
      await prefs.setStringList('savedKeywords', savedKeywords);
    }
  }

  Future<void> deleteKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedKeywords.remove(keyword);
      prefs.setStringList('savedKeywords', savedKeywords);
    });
  }

  // Method to display saved keywords
  Widget buildSavedKeywordsList() {
    return SingleChildScrollView(
      child: Column(
        children: savedKeywords.map((keyword) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: Text(keyword),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 30,
                      color: Color.fromRGBO(59, 99, 53, 1),
                    ),
                    onPressed: () => deleteKeyword(keyword),
                  ),
                  onTap: () {
                    setState(() {
                      searchTerm =
                          keyword; // Set the search term to the selected keyword
                    });
                    fetchSanPhams(
                        keyword); // Fetch products based on the selected keyword
                  },
                ),
              ),
              const Divider(thickness: 1), // Add spacing here
            ],
          );
        }).toList(),
      ),
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
            child: const ImageIcon(
              AssetImage('lib/assets/arrow_back.png'),
              size: 49,
            ),
          ),
        ),
        title: const Text('Tìm kiếm'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchTerm =
                          value.trim(); // Trim whitespace from search term
                    });
                    if (searchTerm.isNotEmpty) {
                      fetchSanPhams(searchTerm);
                    } else {
                      setState(() {
                        sanphams = [];
                        filteredSanphams = [];
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Color.fromRGBO(131, 183, 60, 1),
                        size: 30,
                      ),
                      onPressed:
                          navigateToResults, // Call navigateToResults when search icon is pressed
                    ),
                    hintText: "Tìm kiếm sản phẩm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ),
            searchTerm.isEmpty
                ? SizedBox(
                    height: 500,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: ListTile(
                            leading: Text(
                              "Lịch sử",
                              style: TextStyle(
                                  color: Color.fromRGBO(59, 99, 53, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              "Xóa",
                              style: TextStyle(
                                  color: Color.fromRGBO(248, 158, 25, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const Divider(thickness: 2),
                        buildSavedKeywordsList(),
                      ],
                    ),
                  )
                : filteredSanphams.isEmpty
                    ? const Center(child: Text("No results found"))
                    : SizedBox(
                        height: 500,
                        child: ListView.builder(
                          itemCount: filteredSanphams.length,
                          itemBuilder: (context, index) {
                            final product = filteredSanphams[
                                index]; // Get the ProductModel instance
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailProductScreen(
                                        product:
                                            product, isfavorited: product.isFavorited,), // Pass the product instance
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: product.imageProduct.isNotEmpty
                                          ? Image.network(
                                              product.imageProduct,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return Image.asset(
                                                  'lib/assets/avt2.jpg', // Ensure this path is correct
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : const Icon(Icons.image, size: 50),
                                    ),
                                    title: Text(product.nameProduct),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Đơn giá bán: ${product.donGiaBan}"),
                                        Text(
                                          "Mô tả: ${product.moTa}",
                                          maxLines: 2, // Limit to one line
                                          overflow: TextOverflow
                                              .ellipsis, // Show ellipsis when overflowed
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(thickness: 1),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
