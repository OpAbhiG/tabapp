// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// // import 'package:intl/intl.dart';
// // import 'package:login_registration_screen/models/doctor.dart';
// // import '../models/doctor.dart';
// import '../APIServices/base_api.dart';
// // import 'booking_confirmation_screen.dart';
// // import 'doctor_nav_screen.dart';
// import 'package:http/http.dart' as http;
//
// import '../VideoCall/video_call_screen.dart';
//
// class defaultpay extends StatefulWidget {
//
//   const defaultpay({super.key,
//   });
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
// class _PaymentScreenState extends State<defaultpay> {
//   bool isCashSelected = false;
//
//
//
//   DateTime selectedDate = DateTime.now();
//   String? selectedTimeSlot;
//   int? selectedDoctor;
//   bool isLoading = true;
//
//
//   // List<Map<String, dynamic>> doctors = [
//   //   {'id': '', 'full_name': ''}];
//   //
//   // Future<String?> getToken() async {
//   //   try {
//   //     var box = await Hive.openBox('userBox');
//   //     final token = box.get('authToken');
//   //     print('Token retrieved: $token');
//   //     return token;
//   //   } catch (e) {
//   //     print('Error retrieving token: $e');
//   //     return null;
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF243B6D),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Payment',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Text(
//             //
//             //   selectedDoctor != null && doctors.any((doctor) => doctor['id'] == selectedDoctor)
//             //       ? 'Dr. ${doctors.firstWhere((doctor) => doctor['id'] == selectedDoctor)['full_name']}'
//             //       : 'No doctor selected',
//             //   style: TextStyle(
//             //     fontSize: 16,
//             //     color: Colors.black87,
//             //   ),
//             // ),
//
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//
//               children: [
//                 // Icon(Icons.calendar_today, size: 20),
//                 // SizedBox(width: 15),
//                 // Text( DateFormat('MMM dd, yyyy').format(widget.date)
//                 //   , style: TextStyle(fontSize: 15),),
//                 // Spacer(),
//                 SizedBox(width: 10),
//                 // Icon(Icons.access_time, size: 20),
//                 // SizedBox(width: 10),
//                 // Text(widget.time, style: TextStyle(fontSize: 15),),
//                 // SizedBox(width: 10),
//                 // Text( 'Rs ${widget.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 15,
//                 //   fontWeight: FontWeight.bold,
//                 //   color: Colors.green,
//                 // ),),
//               ],
//             ),
//
//             SizedBox(height: 34),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 leading: Icon(Icons.money, color: Colors.green),
//                 title: Text('Cash'),
//                 trailing: Radio(
//                   value: true,
//                   groupValue: isCashSelected,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       isCashSelected = value!;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             // Spacer(),
//
//             const SizedBox(height: 80),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       //done
//                       if (isCashSelected) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Row(
//                               children: [
//                                 const Icon(Icons.check_circle, color: Colors.white),
//                                 const SizedBox(width: 10),
//                                 const Expanded(
//                                   child: Text(
//                                     'Payment successfully Done',
//                                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             backgroundColor: const Color(0xFF40BF78),
//                             behavior: SnackBarBehavior.floating,
//                             margin: const EdgeInsets.all(16),
//                             elevation: 8,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             duration: const Duration(seconds: 3),
//                           ),
//                         );
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => VideoCallScreen(userId: '',appointmentId: '',
//                               // fullName: widget.full_name,
//                               // doctorId: widget.doctor_id,
//                               // date: widget.date,
//                               // time: widget.time,
//                               // amount: widget.amount,
//                             ),
//                           ),
//                         );
//                       } else {
//                         // ScaffoldMessenger.of(context).showSnackBar(
//                         //   const SnackBar(
//                         //     content: Text('Please select Cash as the payment method.'),
//                         //     duration: Duration(seconds: 2),
//                         //   ),
//                         // );
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Container(
//                               alignment: Alignment.center,
//                               height: 12, // Adjust height if needed
//                               child: Center(
//                                 child: Text(
//                                   'Please select payment method',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                             // backgroundColor: Colors.black.withOpacity(0.7), // Transparent black
//                             backgroundColor: Colors.red,
//                             behavior: SnackBarBehavior.floating, // Floating SnackBar
//                             margin: EdgeInsets.symmetric(horizontal: 120, vertical: 10), // Adjust padding
//                             elevation: 0, // Remove shadow
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5), // Rounded corners
//                             ),
//                             duration: Duration(seconds: 2), // Visible for 2 seconds
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF1A237E),
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                     ),
//                     child: Text('Confirm',style: TextStyle(color: Colors.white),),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                     ),
//                     child: Text('Cancel',style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }