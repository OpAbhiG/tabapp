// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class ScreenSaverScreen extends StatefulWidget {
//   const ScreenSaverScreen({super.key});
//
//   @override
//   _ScreenSaverScreenState createState() => _ScreenSaverScreenState();
// }
//
// class _ScreenSaverScreenState extends State<ScreenSaverScreen> {
//   late VideoPlayerController _controller;
//   int _currentVideoIndex = 0;
//
//   // List of video assets
//   final List<String> _videos = [
//     'assets/vdo1.mp4',
//     'assets/vdo2.mp4',
//     'assets/vdo3.mp4',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo(_videos[_currentVideoIndex]);
//   }
//
//   void _initializeVideo(String videoPath) {
//     _controller = VideoPlayerController.asset(videoPath)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//         _controller.setLooping(false); // Disable looping for slideshow effect
//         _controller.addListener(_videoListener);
//       });
//   }
//
//   void _videoListener() {
//     if (_controller.value.position >= _controller.value.duration) {
//       _playNextVideo();
//     }
//   }
//
//   void _playNextVideo() {
//     _controller.removeListener(_videoListener);
//     _controller.dispose();
//
//     setState(() {
//       _currentVideoIndex = (_currentVideoIndex + 1) % _videos.length;
//     });
//
//     _initializeVideo(_videos[_currentVideoIndex]);
//   }
//
//   @override
//   void dispose() {
//     _controller.removeListener(_videoListener);
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           child: VideoPlayer(_controller),
//         )
//             : const CircularProgressIndicator(), // Show loader while initializing
//       ),
//     );
//   }
// }
