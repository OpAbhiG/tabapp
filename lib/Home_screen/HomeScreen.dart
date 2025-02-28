// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../Connecting_screen/ConnectingScreen.dart';
// import '../sliding_Card/Sliding_Card.dart';
// //
// // class TeleClinicCards extends StatefulWidget {
// //   const TeleClinicCards({Key? key}) : super(key: key);
// //
// //   @override
// //   State<TeleClinicCards> createState() => _TeleClinicCardsState();
// // }
// //
// // class _TeleClinicCardsState extends State<TeleClinicCards> {
// //   void _handleNavigation(BuildContext context, bool isDoctor) {
// //     if (isDoctor) {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) =>  DemoApp()),
// //       );
// //     } else {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) => const ConnectingScreen()),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF1e3a8a), // Dark blue background
// //       body: SafeArea(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.start,
// //             children: [
// //               const SizedBox(height: 32),
// //               // Logo Image
// //               Image.asset(
// //                 'assets/btlogo.png',
// //                 height: 100,
// //                 fit: BoxFit.contain,
// //                 alignment: Alignment.center,
// //               ),
// //               const SizedBox(height: 48),
// //               // Cards Container
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // Doctor Card
// //                     _buildCard(
// //                       image: 'assets/doctor.png',
// //                       title: 'Doctor?',
// //                       price: '₹199/-',
// //                       isDoctor: true,
// //                     ),
// //                     const SizedBox(width: 16),
// //                     // Pharmacist Card
// //                     _buildCard(
// //                       image: 'assets/phy.png',
// //                       title: 'PHARMACIST?',
// //                       price: 'FREE!',
// //                       isDoctor: false,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCard({
// //     required String image,
// //     required String title,
// //     required String price,
// //     required bool isDoctor,
// //   }) {
// //     return Container(
// //       width: 200,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         children: [
// //           // Image
// //           ClipRRect(
// //             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
// //             child: Image.asset(
// //               image,
// //               height: 200,
// //               width: 200,
// //               fit: BoxFit.cover,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           // Title
// //           Text(
// //             title,
// //             style: const TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.red,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           // Price
// //           Text(
// //             price,
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.red,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           // Button
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             child:
// //             ElevatedButton(
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.redAccent,
// //                 foregroundColor: Colors.white,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(30), // Rounded button corners
// //                 ),
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 15,
// //                   vertical: 12,
// //                 ),
// //                 elevation: 8,
// //               ),
// //               onPressed: () => _handleNavigation(context, isDoctor),
// //               child: const Text(
// //                 'TALK NOW',
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //
// //           ),
// //           const SizedBox(height: 12),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// class ResponsiveCardDesign extends StatefulWidget {
//   @override
//   _ResponsiveCardDesignState createState() => _ResponsiveCardDesignState();
// }
// class _ResponsiveCardDesignState extends State<ResponsiveCardDesign> {
//   // Flag to toggle between English and Hindi
//   bool isEnglish = true;
//   late Timer _timer;
//   @override
//   void initState() {
//     super.initState();
//     // Set a timer to toggle the language every 2 seconds
//     _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       setState(() {
//         isEnglish = !isEnglish;
//       });
//     });
//   }
//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     backgroundColor: const Color(0xFF1e3a8a), // Dark blue background
//   //
//   //     body: Center(
//   //       child: LayoutBuilder(
//   //         builder: (context, constraints) {
//   //           bool isTabletOrDesktop = constraints.maxWidth > 600;
//   //           return Padding(
//   //               padding: const EdgeInsets.all(20.0),
//   //               child: Column(
//   //                   mainAxisSize: MainAxisSize.min,
//   //                   mainAxisAlignment: MainAxisAlignment.center,
//   //                   children: [
//   //                     Center(
//   //                       child: Image.asset(
//   //                         'assets/btlogo.png',
//   //                         height: 100,
//   //                         fit: BoxFit.contain,
//   //                         alignment: Alignment.center,
//   //                       ),
//   //                     ),
//   //                     const SizedBox(height: 30), // Space below the logo
//   //                     Row(
//   //                       mainAxisAlignment: MainAxisAlignment.center,
//   //                       children: [
//   //                         Expanded(
//   //                           flex: isTabletOrDesktop ? 1 : 0,
//   //                           child: CardWidget(
//   //                             imagePath: 'assets/doctor.png',
//   //                             title: isEnglish ? 'DOCTOR?' : 'डॉक्टर?',
//   //                             subtitle: isEnglish ? '₹199/-' : '₹१९९/-',
//   //                             buttonLabel: isEnglish ? 'TALK NOW' : 'अभी बात करें',
//   //                             buttonColor: Colors.red,
//   //                             onPressed: () {
//   //                               // Doctor button action
//   //                               Navigator.push(
//   //                                 context,
//   //                                 MaterialPageRoute(builder: (context) =>  DemoApp()),
//   //                               );
//   //                             },
//   //                           ),
//   //                         ),
//   //                         if (isTabletOrDesktop) const SizedBox(width: 20), // Space between cards
//   //                         Expanded(
//   //                           flex: isTabletOrDesktop ? 1 : 0,
//   //                           child: CardWidget(
//   //                             imagePath: 'assets/phy.png',
//   //                             title: isEnglish ? 'PHARMACIST?' : 'फार्मासिस्ट?',
//   //                             subtitle: isEnglish ? 'FREE!' : 'नि: शुल्क!',
//   //                             buttonLabel: isEnglish ? 'TALK NOW' : 'अभी बात करें',
//   //                             buttonColor: Colors.red,
//   //                             onPressed: () {
//   //                               // Pharmacist button action
//   //                               Navigator.push(
//   //                                 context,
//   //                                 MaterialPageRoute(builder: (context) => const ConnectingScreen()),
//   //                               );
//   //                             },
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ],
//   //                   Expanded(child: NewsTickerScreen()),
//   //               )
//   //           );
//   //         },
//   //
//   //       ),
//   //     ),
//   //     // NewsTickerScreen(),
//   //
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1e3a8a), // Dark blue background
//       body: Center(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             bool isTabletOrDesktop = constraints.maxWidth > 600;
//             return Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: Image.asset(
//                       'assets/btlogowhite.jpg',
//                       height: 100,
//                       fit: BoxFit.contain,
//                       alignment: Alignment.center,
//                     ),
//                   ),
//                   const SizedBox(height: 30), // Space below the logo
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         flex: isTabletOrDesktop ? 1 : 0,
//                         child: CardWidget(
//                           imagePath: 'assets/doctor.png',
//                           title: isEnglish ? 'DOCTOR?' : 'डॉक्टर?',
//                           subtitle: isEnglish ? '₹199/-' : '₹१९९/-',
//                           buttonLabel: isEnglish ? 'TALK NOW' : 'अभी बात करें',
//                           buttonColor: Colors.red,
//                           onPressed: () {
//                             // Doctor button action
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => DemoApp()),
//                             );
//                           },
//                         ),
//                       ),
//                       if (isTabletOrDesktop) const SizedBox(width: 20), // Space between cards
//                       Expanded(
//                         flex: isTabletOrDesktop ? 1 : 0,
//                         child: CardWidget(
//                           imagePath: 'assets/phy.png',
//                           title: isEnglish ? 'PHARMACIST?' : 'फार्मासिस्ट?',
//                           subtitle: isEnglish ? 'FREE!' : 'नि: शुल्क!',
//                           buttonLabel: isEnglish ? 'TALK NOW' : 'अभी बात करें',
//                           buttonColor: Colors.red,
//                           onPressed: () {
//                             // Pharmacist button action
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => const ConnectingScreen()),
//                             );
//                           },
//                         ),
//
//                       ),
//                     ],
//                   ),
//
//
//                   Expanded(
//                     child: Container(
//                       color: const Color(0xFF1e3a8a), // Match the dark blue background
//                       child: NewsTickerScreen(),
//                     ),
//                   ),
//                 ],
//               ),
//
//             );
//           },
//         ),
//       ),
//     );
//   }
//
// }
//
// class CardWidget extends StatelessWidget {
//   final String imagePath;
//   final String title;
//   final String subtitle;
//   final String buttonLabel;
//   final Color buttonColor;
//   final VoidCallback onPressed;
//
//   CardWidget({
//     required this.imagePath,
//     required this.title,
//     required this.subtitle,
//     required this.buttonLabel,
//     required this.buttonColor,
//     required this.onPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(
//         width: 300,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Larger Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset(
//                 imagePath,
//                 height: 200,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Animated Subtitle Text
//             // AnimatedSwitcher(
//             //   duration: const Duration(milliseconds: 500),
//             //   transitionBuilder: (child, animation) => FadeTransition(
//             //     opacity: animation,
//             //     child: child,
//             //   ),
//             //   child: Text(
//             //     subtitle,
//             //     key: ValueKey<String>(subtitle), // Key to track text changes
//             //     textAlign: TextAlign.center,
//             //     style: GoogleFonts.poppins(
//             //       fontSize: 16,
//             //       color: Colors.grey[600],
//             //     ),
//             //   ),
//             // ),
//             // Title Text
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Subtitle Text
//             Text(
//               subtitle,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Button
//             ElevatedButton(
//               onPressed: onPressed,
//               style: ElevatedButton.styleFrom(
//                 elevation: 10,
//                 shadowColor: Colors.black,
//                 animationDuration: const Duration(milliseconds: 200),
//                 backgroundColor: buttonColor,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 buttonLabel,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // class ImageCarousel extends StatelessWidget {
// // infinity slide image animation
// //   final List imageList = ['Dr_Cardiologist.png', 'Dr_Cardiothoracic-Surgeon.png', 'Dr_Dermatologist.png', 'Dr_Oncologist.png', 'Dr_Pediatrician.png', 'Dr_Psychiatrist.png', 'phy.png',];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return CarouselSlider(
// //       items: imageList.map((item) => Container(
// //         child: Image.asset(item, fit: BoxFit.contain, width: double.infinity),
// //       )).toList(),
// //       options: CarouselOptions(
// //         aspectRatio: 16/9,
// //         enlargeCenterPage: true,
// //         autoPlay: true,
// //         autoPlayInterval: Duration(seconds: 3),
// //         autoPlayAnimationDuration: Duration(milliseconds: 800),
// //         pauseAutoPlayOnTouch: true,
// //       ),
// //     );
// //   }
// // }
//
//
// class NewsTickerScreen extends StatefulWidget {
//   @override
//   _NewsTickerScreenState createState() => _NewsTickerScreenState();
// }
// class _NewsTickerScreenState extends State<NewsTickerScreen> {
//   final String _newsText = "Welcome to Bharat Tele Clinic! Consult top doctors for quick advice and get genuine medicines delivered fast. Your journey to better health starts here!";
//   late ScrollController _scrollController;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _startScrolling();
//   }
//
//   void _startScrolling() async {
//     while (true) {
//       await Future.delayed(const Duration(milliseconds: 10), () {
//         if (_scrollController.hasClients) {
//           final maxScrollExtent = _scrollController.position.maxScrollExtent;
//           final currentScrollPosition = _scrollController.offset;
//
//           if (currentScrollPosition >= maxScrollExtent) {
//             _scrollController.jumpTo(0.0);
//           } else {
//             _scrollController.jumpTo(currentScrollPosition + 1);
//           }
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF1e3a8a),
//       body: Stack(
//         children: [
//           // Main content can go here
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               width: MediaQuery.of(context).size.width / 2,
//               color: Color(0xFFF39200),//text bk
//               padding: const EdgeInsets.symmetric(vertical: 10.0),
//               height: 50.0, // Fixed height for the ticker
//               child: ListView.builder(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, index) {
//                   return Row(
//                     children: [
//                       Text(
//                         _newsText,
//                         style: GoogleFonts.poppins(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
//                       ),
//
//                       const SizedBox(width: 20), // Space between repetitions
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
