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
//   // void _makePayment() {
//   //   int amountInPaise = (double.parse(widget.price) * 100).toInt(); // Convert to paise
//   //
//   //   var options = {
//   //
//   //     'key': 'rzp_test_USRnc9D0LcPYTb', // Replace with your Razorpay key
//   //     'amount': amountInPaise, // Amount in paise (e.g., 1000 = ₹10)
//   //     'name': "hello",
//   //     'description': 'Doctor Consultation Fees',
//   //     'prefill': {
//   //       'contact': "welcome",
//   //       'email': 'bharat@example.com',
//   //     },
//   //     'theme': {'color': '#3399cc'},
//   //   };
//   //
//   //   try {
//   //     _razorpay.open(options);
//   //   } catch (e) {
//   //     print(e.toString());
//   //   }
//   // }
// //v2
//   void _makePayment() {
//     int amountInPaise = (double.parse(widget.price) * 100).toInt(); // Convert to paise
//
//     var options = {
//       'key': 'rzp_test_USRnc9D0LcPYTb', // Replace with your Razorpay key
//       'amount': amountInPaise, // Amount in paise (e.g., 1000 = ₹10)
//       'currency': 'INR',
//       'name': "hello",
//       'description': 'Doctor Consultation Fees',
//       'prefill': {
//         'contact': widget.phoneNumber,
//         'email': 'bharat@example.com',
//       },
//       'theme': {'color': '#3399cc'},
//       'method': {
//         'qr': true // This will enable only QR Code payment
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
//     Future.delayed(const Duration(seconds: 0), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ConnectingScreen(
//
//           token: widget.token,
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
//                           ),import 'dart:async';


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



import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIServices/base_api.dart';
import '../Connecting_screen/ConnectingScreen.dart';
import '../topSection/topsection.dart';

class PaymentScreen extends StatefulWidget {
  final String token;
  final String name;
  final String phoneNumber;
  final String price;
  final String specialityId; // Added specialty ID

  const PaymentScreen({
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

class _PaymentScreenState extends State<PaymentScreen> {
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
      });

      // Add form-data fields (as text)
      request.fields['speciality_id'] = widget.specialityId; // Ensure it's a string
      request.fields['amount'] = widget.price;
      request.fields['name'] = widget.name;
      request.fields['phone'] = widget.phoneNumber;

      print('Sending QR Code Request:');
      print('URL: $url');
      print('Headers: ${request.headers}');
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
          _rezorpay_orderId=data['razorpay_order_id'];
          _isLoading = false;
        });

        _startPaymentStatusCheck();
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

  // Start timer to check payment status periodically
  void _startPaymentStatusCheck() {
    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPaymentStatus();
    });
  }

  // Check payment status
  Future<void> _checkPaymentStatus() async {
    if (_qrCodeId == null) return;
    if (_rezorpay_orderId == null) {
      print(_rezorpay_orderId);
      print(_qrCodeId);
      print('QR Code ID is null, skipping request.');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$baseapi/tab/live-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          // 'qr_code_id': _qrCodeId,
          'razorpay_order_id': _rezorpay_orderId, // Change from qr_code_id
          // Add any other required parameters
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);

        // Check if payment was successful
        if (data['event'] == 'payment.captured') {
          _paymentCheckTimer?.cancel();
          _paymentId = data['payload']['payment']['entity']['id'];
          _handlePaymentSuccess();
        }
      }
    } catch (e) {
      print('Error checking payment status: ${e.toString()}');
    }
  }

  void _handlePaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: $_paymentId")),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConnectingScreen(
          token: widget.token,
          speciality: widget.specialityId,
        )),
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
                                backgroundImage: AssetImage('assets/doctor/d${index + 1}.jpg'),
                                radius: 20,
                              ),
                            )),
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
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
                          decoration: InputDecoration(
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
                        const SizedBox(height: 20),

                        // QR Code Display Section
                        if (_qrCodeUrl != null)
                          Center(
                            child: Column(
                              children: [
                                Image.network(
                                  _qrCodeUrl!,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      width: 200,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text('Failed to load QR code'),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Scan the QR code to complete payment',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Payment status is being checked automatically',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _qrCodeUrl == null
                                    ? () => _generateQRCode()
                                    : null, // Disable once QR is shown
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  _qrCodeUrl == null
                                      ? 'Generate Payment QR'
                                      : 'QR Code Generated',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      title: const Text(
                                        "Cancel Confirmation",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      content: const Text(
                                        "Are you sure you want to cancel? Your progress will not be saved.",
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text(
                                            "Stay",
                                            style: TextStyle(color: Colors.green, fontSize: 16),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
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