import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../main.dart';
import '../main.dart';
import '../sliding_Card/Sliding_Card.dart';


// v1
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  // int _currentIndex = 0;
  final List<String> images = [
    'assets/s5.png',
    'assets/s1.jpg',
    'assets/s2.jpg',
    'assets/s3.jpg',
    'assets/s4.jpg',
  ];

  bool _isLongPressing = false;
  int _longPressTimer = 0;
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all session data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startLogoutTimer() {
    setState(() {
      _isLongPressing = true;
      _longPressTimer = 5;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isLongPressing) {
        timer.cancel();
        return;
      }

      setState(() {
        _longPressTimer--;
      });

      if (_longPressTimer <= 0) {
        timer.cancel();
        _logout();
      }
    });
  }

  void _cancelLogoutTimer() {
    setState(() {
      _isLongPressing = false;
      _longPressTimer = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/btclogo.png',
          height: 60, // Adjust height as needed
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,size:20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout, size: 60, color: Colors.red),
                        const SizedBox(height: 15),
                        const Text(
                          'Logout?',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Are you sure you want to log out?\nYou will be returned to the login screen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _logout(); // Your logout function
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Logout', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );

            },
          ),
        ],
      ),


      body: GestureDetector(
        onLongPressStart: (_) => _startLogoutTimer(),
        onLongPressEnd: (_) => _cancelLogoutTimer(),
        onLongPressCancel: () => _cancelLogoutTimer(),
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isLandscape = constraints.maxWidth > constraints.maxHeight;
                  double imageHeight = isLandscape ? constraints.maxHeight * 0.65 : constraints.maxHeight * 0.6;
                  double buttonWidth = isLandscape ? 240 : 280;

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [


                        // Image Carousel
                        SizedBox(
                          height: imageHeight,
                          width: constraints.maxHeight,
                          child: CarouselSlider(
                            items: images.map((item) {
                              return ClipRRect(
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                  width: constraints.maxHeight,
                                ),
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height: imageHeight,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              autoPlayAnimationDuration: const Duration(milliseconds: 500),
                              viewportFraction: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Get Started Button
                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SpecialitiesScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.red,
                            ),
                            child: const Center(
                              child: Text(
                                "GET STARTED",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),

            // Logout timer overlay
            if (_isLongPressing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: (5 - _longPressTimer) / 5,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                          strokeWidth: 6,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Logging out in $_longPressTimer seconds...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Release to cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}

// v2
// class ImageCarousel extends StatelessWidget {
//   const ImageCarousel({super.key});
//
//   final List<String> images = const [
//     'assets/s5.png',
//     'assets/s1.jpg',
//     'assets/s2.jpg',
//     'assets/s3.jpg',
//     'assets/s4.jpg',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             bool isLandscape = constraints.maxWidth > constraints.maxHeight;
//             double imageHeight = isLandscape ? constraints.maxHeight * 0.65 : constraints.maxHeight * 0.5;
//             double logoHeight = isLandscape ? 80 : 120;
//             double buttonWidth = isLandscape ? 240 : 280;
//
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Logo at the Top
//                     Image.asset(
//                       'assets/btclogo.png',
//                       height: logoHeight,
//                       fit: BoxFit.contain,
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Image Carousel
//                     SizedBox(
//                       height: imageHeight,
//                       width: constraints.maxHeight,
//                       child: CarouselSlider(
//                         items: images.map((item) {
//                           return ClipRRect(
//                             borderRadius: BorderRadius.circular(0),
//                             child: Image.asset(
//                               item,
//                               fit: BoxFit.cover,
//                               width: constraints.maxHeight,
//                             ),
//                           );
//                         }).toList(),
//                         options: CarouselOptions(
//                           height: imageHeight,
//                           enlargeCenterPage: true,
//                           autoPlay: true,
//                           autoPlayInterval: const Duration(seconds: 3),
//                           autoPlayAnimationDuration: const Duration(milliseconds: 1200),
//                           viewportFraction: 1,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 80),
//
//                     // Get Started Button
//                     SizedBox(
//                       width: buttonWidth,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => SpecialitiesScreen()),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           elevation: 6,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Center(
//                           child: Text(
//                             "GET STARTED",
//                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
