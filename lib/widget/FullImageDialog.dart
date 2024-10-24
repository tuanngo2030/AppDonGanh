import 'package:flutter/material.dart';

class FullImageDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  FullImageDialog({required this.images, required this.initialIndex});

  @override
  _FullImageDialogState createState() => _FullImageDialogState();
}

class _FullImageDialogState extends State<FullImageDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Quay lại hình đầu tiên
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = widget.images.length - 1; // Quay về hình cuối cùng
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Toàn màn hình với nền đen
      body: Stack(
        children: [
          // Sử dụng PageView để lướt qua các hình ảnh
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(10),
                minScale: 0.5,
                maxScale: 5.0,
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain, // Sử dụng contain để giữ tỉ lệ hình ảnh
                    width: double.infinity, // Kích thước full màn hình
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 223, 223, 223)),
              onPressed: _previousImage,
              iconSize: 50,
            ),
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: const Color.fromARGB(255, 223, 223, 223)),
              onPressed: _nextImage,
              iconSize: 50,
            ),
          ),
          // Nút thoát
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: const Color.fromARGB(255, 223, 223, 223)),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
          ),
        ],
      ),
    );
  }
}
