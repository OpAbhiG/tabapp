import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
// import '../main.dart';
import '../sliding_Card/Sliding_Card.dart';


// v1
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final List<String> images = [
    'assets/s5.png',
    'assets/s1.jpg',
    'assets/s2.jpg',
    'assets/s3.jpg',
    'assets/s4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isLandscape = constraints.maxWidth > constraints.maxHeight;
            double imageHeight = isLandscape ? constraints.maxHeight * 0.65 : constraints.maxHeight * 0.5;
            double logoHeight = isLandscape ? 80 : 90;
            double buttonWidth = isLandscape ? 240 : 280;

            return Column(
              children: [
                // Top Logo
                const SizedBox(height: 10,),
                Padding(padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: Image.asset(
                      'assets/btclogo.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Spacer between logo and carousel
                const SizedBox(height: 20),

                // Carousel Image
                Expanded(
                  child: Center(
                    child: CarouselSlider(
                      items: images.map((item) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image.asset(
                            item,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: imageHeight,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayAnimationDuration: const Duration(milliseconds: 500),
                        viewportFraction: 1,
                      ),
                    ),
                  ),
                ),

                // Spacer before button
                const SizedBox(height: 10),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SpecialitiesScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "GET STARTED",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
