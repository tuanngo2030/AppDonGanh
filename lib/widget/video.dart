  // // Initialize video player when a video is picked
  // Future<void> _pickVideo() async {
  //   final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _video = File(pickedFile.path);
  //       _videoController = VideoPlayerController.file(_video!)
  //         ..initialize().then((_) {
  //           setState(() {}); // Rebuild the widget when the video is ready to play
  //           _videoController!.play(); // Auto-play the video
  //         });
  //     });
  //   }
  // }
