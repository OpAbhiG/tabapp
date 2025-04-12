// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../Connecting_screen/ConnectingScreen.dart';
// import '../topSection/topsection.dart';
//
// class pay extends StatefulWidget {
//   final String token;
//   final String name;
//   final String phoneNumber;
//   final String price;
//
//   const pay({super.key,
//     required this.token, required this.name, required this.phoneNumber, required this.price
//   });
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
// class _PaymentScreenState extends State<pay> {
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//   }
//
//   void _makePayment() {
//     int amountInPaise = (double.parse(widget.price) * 100).toInt(); // Convert to paise
//
//     var options = {
//       'key': 'rzp_test_USRnc9D0LcPYTb', // Replace with your Razorpay key
//       'amount': amountInPaise, // Amount in paise (e.g., 1000 = ₹10)
//       'currency': 'INR',
//       'name': widget.name,
//       // 'description': 'Doctor Consultation Fees',
//       'prefill': {
//         'contact': widget.phoneNumber,
//         // 'email': 'bharat@example.com',
//       },
//       'theme': {'color': '#3399cc'},
//       'method': {
//         'qr': true
//       },
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print(e.toString());
//     }
//   }
//
//
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Payment Successful: ${response.paymentId}")));
//
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ConnectingScreen(
//           token: widget.token,
//           speciality: '1',
//         )),
//       );
//     }
//     );
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment Failed: ${response.message}")),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
//     );
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 15,),
//                 const TopSection(), // This adds the top header
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 4,
//                     margin: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.05,
//                       vertical: 20,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Confirm & Pay',
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.06,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               ...List.generate(3, (index) => Padding(
//                                 padding: const EdgeInsets.only(right: 6.0),
//                                 child: CircleAvatar(
//                                   backgroundImage: AssetImage('assets/doctor/d${index + 1}.jpg'),
//                                   radius: 20,
//                                 ),
//                               )),
//                               const CircleAvatar(
//                                 radius: 20,
//                                 backgroundColor: Colors.grey,
//                                 child: Text(
//                                   '+170',
//                                   style: TextStyle(fontSize: 12, color: Colors.black),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           const Row(
//                             children: [
//                               Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
//                               SizedBox(width: 5),
//                               Expanded(
//                                 child: Text(
//                                   '93% of users found online consultation helpful',
//                                   style: TextStyle(fontSize: 14),
//                                   softWrap: true,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 5),
//                           const Row(
//                             children: [
//                               Icon(Icons.phone_android, color: Colors.green, size: 20),
//                               SizedBox(width: 5),
//                               Expanded(
//                                 child: Text(
//                                   'Consultation will happen only on mobile app',
//                                   style: TextStyle(fontSize: 14),
//                                   softWrap: true,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           const Text(
//                             'Patient Name',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 5),
//                           const TextField(
//                             decoration: InputDecoration(
//                               hintText: 'Enter your full name',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           // const SizedBox(height: 15),
//                           // Row(
//                           //   children: [
//                           //     const Expanded(
//                           //       child: TextField(
//                           //         decoration: InputDecoration(
//                           //           hintText: 'Enter coupon code',
//                           //           border: OutlineInputBorder(),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //     const SizedBox(width: 8),
//                           //     ElevatedButton(
//                           //       onPressed: () {},
//                           //       style: ElevatedButton.styleFrom(
//                           //         backgroundColor: Colors.grey[300],
//                           //         padding: const EdgeInsets.symmetric(horizontal: 15),
//                           //       ),
//                           //       child: const Text(
//                           //         'Apply',
//                           //         style: TextStyle(color: Colors.black),
//                           //       ),
//                           //     ),
//                           //   ],
//                           // ),
//                           const SizedBox(height: 15),
//                           const Text(
//                             'Final Fee',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '₹${widget.price}',
//                             style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     _makePayment();
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                     padding: const EdgeInsets.symmetric(vertical: 14),
//                                   ),
//                                   child: const Text(
//                                     'Continue to payment',
//                                     style: TextStyle(color: Colors.white, fontSize: 16),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               TextButton(
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                         title: const Text(
//                                           "Cancel Confirmation",
//                                           style: TextStyle(fontWeight: FontWeight.bold),
//                                         ),
//                                         content: const Text(
//                                           "Are you sure you want to cancel? Your progress will not be saved.",
//                                           style: TextStyle(color: Colors.black87),
//                                         ),
//                                         actions: [
//                                           /// **Stay Button**
//                                           TextButton(
//                                             onPressed: () => Navigator.of(context).pop(), // Close dialog
//                                             child: const Text(
//                                               "Stay",
//                                               style: TextStyle(color: Colors.green, fontSize: 16),
//                                             ),
//                                           ),
//
//                                           /// **Confirm Cancel Button**
//                                           ElevatedButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop(); // Close confirmation dialog
//                                               Navigator.of(context).pop(); // Go back
//                                               Navigator.of(context).pop(); // Close confirmation dialog
//                                               Navigator.of(context).pop(); // Go back
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.red, // Red cancel button
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(5),
//                                               ),
//                                             ),
//                                             child: const Text(
//                                               "Cancel",
//                                               style: TextStyle(color: Colors.white, fontSize: 16),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                                 child: const Text(
//                                   'Cancel',
//                                   style: TextStyle(
//                                       color: Colors.red,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//               ],
//             )
//
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//
//   }
// }

//
// QR code payment
//

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIServices/base_api.dart';
import '../Connecting_screen/ConnectingScreen.dart';
import '../topSection/topsection.dart';
import 'package:crypto/crypto.dart';

String generateSignature(String payload, String secretKey) {
  final key = utf8.encode(secretKey);
  final bytes = utf8.encode(payload);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(bytes);

  return digest.toString();
  // return digest.bytes.map((b) => b.toRadixString(16).padLeft(2,'0')).join();
}
class pay extends StatefulWidget {
  final String token;
  final String name;
  final String phoneNumber;
  final String price;
  final String specialityId; // Added specialty ID

  const pay({
    super.key,
    required this.token,
    required this.name,
    required this.phoneNumber,
    required this.price,
    required this.specialityId,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}
class _PaymentScreenState extends State<pay> {

  bool _isLoading = false;
  String? _qrCodeUrl;
  String? _qrCodeId;
  String? _paymentId;
  Timer? _paymentCheckTimer;
  String? _rezorpay_orderId;







  @override
  void initState() {
  super.initState();

  }

  @override
  void dispose() {
  _paymentCheckTimer?.cancel();
  super.dispose();
  }

  void showQRCodeDialog() {
    if (_qrCodeUrl != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // Make the dialog larger overall
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'BHARAT TELEPHARMA PRIVATE LIMITED',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 16),
                  Image.network(
                    _qrCodeUrl!,
                    width: 650,
                    height: 650,
                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 500,
                        height: 500,
                        color: Colors.grey[200],
                        child: const Center(

                          child: Text('Failed to load QR code'),
                        ),
                      );
                    },
                  ),
                  // const SizedBox(height: 16),
                  // const Text(
                  //   'Please wait until payment is confirmed',
                  //   style: TextStyle(fontSize: 20),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      _showErrorMessage("QR Code not available. Please generate again.");
    }
  }
  // Generate QR code from the API
  Future<void> _generateQRCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$baseapi/tab/paymoney-tb');
      final request = http.MultipartRequest("POST", url);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/x-www-form-urlencoded',
      });

      // Specialty mapping
      Map<String, String> specialityMapping = {
        "General Physician": "1",
        "Gynecologist": "2",
        "Sexologist": "3",
        "Dermatologist": "4",
        "Psychiatrist": "5",
        "Gastroenterologist": "6",
        "Pediatrician": "7",
        "Urologist": "8",
        "ENT Specialist": "9",
        "Orthopedist": "10",
        "Cardiologist": "11",
        "Pulmonologist": "12",
        "Neurologist": "13",
        "Endocrinologist": "14",
        "Nephrologist": "15",
        "Psychologist": "16",
        "Nutritionist/Dietitian": "17",
        "Physiotherapist": "18",
        "Oncologist (Consultation Only)": "19",
        "Ophthalmologist": "20",
        "Dentist": "21",
        "Trichologist": "22"
      };

      String mappedSpecialityId = specialityMapping[widget.specialityId] ?? "1";
      request.fields['speciality_id'] = mappedSpecialityId;

      print('Sending QR Code Request:');
      print('URL: $url');
      print('Fields: ${request.fields}');


      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response Status: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        setState(() {
          _qrCodeUrl = data['qr_code_url'];
          _qrCodeId = data['qr_code_id'];
          _rezorpay_orderId = data['razorpay_order_id'];
          _isLoading = false;
        });



        showQRCodeDialog();

        // 🔹 Start checking payment status every 5 seconds
        _paymentCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          _checkPaymentStatus();
        });

      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Failed to generate QR code: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error: ${e.toString()}');
    }
  }

//without pay nav to connecting screen
  // Future<void> _checkPaymentStatus() async {
  //   if (_rezorpay_orderId==null && _qrCodeId == null) {
  //     print('Razorpay Order ID is null, skipping request.');
  //     return;
  //   }
  //
  //   try {
  //     final payload = jsonEncode({
  //       "event": "payment.captured",
  //       "payload": {
  //         "payment": {
  //           "entity": {
  //             "id":_qrCodeId,
  //             "order_id": _rezorpay_orderId,
  //             "amount":widget.price,
  //             "currency":"INR",
  //             "status":"capture"
  //           }
  //         }
  //       }
  //     });
  //
  //     const secretKey = "U2c9VpTGa6a@JxpR@JaB@bu";
  //     final signature = generateSignature(payload, secretKey);
  //
  //     final response = await http.post(
  //       Uri.parse('$baseapi/tab/live-verification'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${widget.token}',
  //         'X-Razorpay-Signature': signature,
  //       },
  //       body: payload,
  //     );
  //
  //     print("---- Payment Status Response ----");
  //     print("---------------------------------");
  //     print('1 Payment Status Check Response: ${response.statusCode}');
  //     print('2 Payment Status Check Body: ${response.body}');
  //     print('3 Sending verification request:');
  //     print('4 Body: $payload');
  //     print('5 Headers: ${response.request?.headers}');
  //     print("---------------------------------");
  //
  //     print('Status Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');
  //     print('Headers: ${response.headers}');
  //
  //     if (response.statusCode != 500) {
  //       _paymentCheckTimer?.cancel(); // Stop checking once verified
  //       _handlePaymentSuccess();
  //       final data = jsonDecode(response.body);
  //       if (data['event'] == 'payment.captured') {
  //         _paymentCheckTimer?.cancel(); // Stop checking once verified
  //         _paymentId = data['payload']?['payment']?['entity']?['id'];
  //         _handlePaymentSuccess();
  //       } else {
  //         print('Payment status message: ${data['message']}');
  //       }
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Exception during payment status check: ${e.toString()}');
  //   }
  // }


///////////////////////////////////////////////////
  //hold QR screen
  Future<void> _checkPaymentStatus() async {
    if (_rezorpay_orderId==null && _qrCodeId == null) {
      print('Razorpay Order ID is null, skipping request.');
      return;
    }

    try {
      final payload = jsonEncode({
        "event": "payment.captured",
        "payload": {
          "payment": {
            "entity": {
              "id":_qrCodeId,
              "order_id": _rezorpay_orderId,
              "amount":widget.price,
              "currency":"INR",
              "status":"capture"
            }
          }
        }
      });

      const secretKey = "U2c9VpTGa6a@JxpR@JaB@bu";
      final signature = generateSignature(payload, secretKey);

      final response = await http.post(
        Uri.parse('$baseapi/tab/live-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'X-Razorpay-Signature': signature,
        },
        body: payload,
      );

      print("---- Payment Status Response ----");
      print("---------------------------------");
      print('1 Payment Status Check Response: ${response.statusCode}');
      print('2 Payment Status Check Body: ${response.body}');
      print('3 Sending verification request:');
      print('4 Body: $payload');
      print('5 Headers: ${response.request?.headers}');
      print("---------------------------------");

      if (response.statusCode == 200) {  // Only process 200 responses
        final data = jsonDecode(response.body);
        if (data['event'] == 'payment.captured') {
          _paymentCheckTimer?.cancel(); // Stop checking once verified
          _paymentId = data['payload']?['payment']?['entity']?['id'];
          _handlePaymentSuccess();
        } else {
          print('Payment status message: ${data['message']}');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception during payment status check: ${e.toString()}');
    }
  }






  void _handlePaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("Payment Successful: $_qrCodeId")),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectingScreen(
            token: widget.token,
            speciality: widget.specialityId,
          ),
        ),
      );
    });
  }

  void _showErrorMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(message)),
  );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              const TopSection(), // This adds the top header
              const SizedBox(height: 10),
              Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 20,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm & Pay',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...List.generate(3, (index) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300], // Placeholder background color
                                backgroundImage: AssetImage('assets/doctor/d${index + 1}.jpg'),
                                onBackgroundImageError: (_, __) {
                                  debugPrint("Image assets/doctor/d${index + 1}.jpg not found, showing placeholder.");
                                },
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/doctor/d${index + 1}.jpg',
                                    fit: BoxFit.cover, // Ensures image is properly cropped
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/doctor/placeholder.jpg', // Placeholder image
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )),

                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey, // Background color for count badge
                              child: Text(
                                '+170',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '93% of users found online consultation helpful',
                                style: TextStyle(fontSize: 14),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Row(
                          children: [
                            Icon(Icons.phone_android, color: Colors.green, size: 20),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Consultation will happen only on mobile app',
                                style: TextStyle(fontSize: 14),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Patient Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: TextEditingController(text: widget.name),
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Final Fee',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${widget.price}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green
                          ),
                        ),
                        // const SizedBox(height: 20),
                        //
                        // // QR Code Display Section
                        // if (_qrCodeUrl != null)
                        //   Center(
                        //     child: Column(
                        //       children: [
                        //         Image.network(
                        //           _qrCodeUrl!,
                        //           height: 200,
                        //           width: 200,
                        //           fit: BoxFit.contain,
                        //           loadingBuilder: (context, child, loadingProgress) {
                        //             if (loadingProgress == null) return child;
                        //             return Center(
                        //               child: CircularProgressIndicator(
                        //                 value: loadingProgress.expectedTotalBytes != null
                        //                     ? loadingProgress.cumulativeBytesLoaded /
                        //                     loadingProgress.expectedTotalBytes!
                        //                     : null,
                        //               ),
                        //             );
                        //           },
                        //           errorBuilder: (context, error, stackTrace) {
                        //             return Container(
                        //               height: 200,
                        //               width: 200,
                        //               color: Colors.grey[200],
                        //               child: const Center(
                        //                 child: Text('Failed to load QR code'),
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //         const SizedBox(height: 16),
                        //         const Text(
                        //           'Scan the QR code to complete payment',
                        //           style: TextStyle(fontWeight: FontWeight.bold),
                        //           textAlign: TextAlign.center,
                        //         ),
                        //         const SizedBox(height: 8),
                        //         Text(
                        //           'Payment status is being checked automatically',
                        //           style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        //           textAlign: TextAlign.center,
                        //         ),
                        //       ],
                        //     ),
                        //   ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _qrCodeUrl == null
                                    ? () => _generateQRCode()
                                    : () => showQRCodeDialog(), // Reopen QR Code Popup
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  _qrCodeUrl == null ? 'Generate Payment QR' : 'View QR Code',
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}