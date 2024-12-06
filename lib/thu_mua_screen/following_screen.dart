import 'package:don_ganh_app/api_services/register_api_service.dart';
import 'package:don_ganh_app/api_services/user_api_service.dart';
import 'package:don_ganh_app/models/user_model.dart';
import 'package:don_ganh_app/thu_mua_screen/other_profile_screen.dart';
import 'package:flutter/material.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  final String title;
  final String chucNang;

  const FollowersScreen(
      {super.key,
      required this.userId,
      required this.title,
      required this.chucNang});

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final UserApiService _apiService = UserApiService();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _apiService.getUserFollowers(widget.userId);

      // Convert data from JSON into a list of NguoiDung
      List<NguoiDung> followers = (data['followers'] as List)
          .map((userJson) => NguoiDung.fromJson(userJson))
          .toList();

      List<NguoiDung> followings = (data['followings'] as List)
          .map((userJson) => NguoiDung.fromJson(userJson))
          .toList();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          userData = {'followers': followers, 'followings': followings};
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle the error by stopping the loading state and showing a SnackBar
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Image.asset(
              'lib/assets/arrow_back.png',
              width: 30,
              height: 30,
              color: const Color.fromRGBO(41, 87, 35, 1),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text('No data available'))
              : ListView(
                  children: [
                    widget.chucNang == 'followers'
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Followers:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Followings:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                    ..._buildUserList(widget.chucNang == 'followers'
                        ? userData!['followers']
                        : userData!['followings']
                      ),
                  ],
                ),
    );
  }

  List<Widget> _buildUserList(List<NguoiDung> users) {
    return users.map((user) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => O(
                nguoiDung:
                    user, // Pass the NguoiDung object to the profile screen
              ),
            ),
          ).then((_) {
            _fetchData();
          });
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.anhDaiDien ??
                'https://example.com/default_image.png'), // Default image if null
            onBackgroundImageError: (exception, stackTrace) {
              // If unable to load image, use default
              'lib/assets/avt2.jpg';
            },
          ),
          title: Text(user.tenNguoiDung ?? 'Unknown User'),
          subtitle: Text(user.gmail ?? 'No Email'),
        ),
      );
    }).toList();
  }
}
