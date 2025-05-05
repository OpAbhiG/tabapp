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


// QR code payment
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIServices/base_api.dart';
import '../Connecting_screen/ConnectingScreen.dart';
import '../screen_saver/screen_saveradd.dart';
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

  static const String RAZORPAY_KEY_ID = "rzp_live_Erfo0J9KhDydDn";
  static const String RAZORPAY_KEY_SECRET="ajvN3dobkPGjLmxszHc3QIws";

  // Add countdown variables
  Timer? _countdownTimer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  bool _isTimedOut = false;



  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _paymentCheckTimer?.cancel();
    _countdownTimer?.cancel(); // Also cancel countdown timer



    super.dispose();
  }


  // Format seconds into mm:ss
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Start countdown timer for 5 minutes

  void _startCountdownTimer({VoidCallback? onTick}) {
    _remainingSeconds = 300;
    _isTimedOut = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;

        if (onTick != null) {
          onTick();
        }

        setState(() {});
      } else {
        _isTimedOut = true;
        timer.cancel();
        _paymentCheckTimer?.cancel();

        // Show dialog with auto-navigation countdown
        _showExpirationDialogWithAutoNavigate();
      }
    });
  }

  void _showExpirationDialogWithAutoNavigate() {
    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Store context reference at the beginning
    final BuildContext currentContext = context;

    // Dialog auto-dismiss countdown seconds
    int dialogCountdown = 15;
    BuildContext? dialogContext;
    Timer? countdownTimer;
    bool dialogActive = true;

    // Create a separate stream controller to update the UI
    final countdownController = StreamController<int>.broadcast();
    countdownController.add(dialogCountdown);

    // First show the dialog
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return StreamBuilder<int>(
          stream: countdownController.stream,
          initialData: dialogCountdown,
          builder: (context, snapshot) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.timer_off,
                    color: Colors.red[700],
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Payment Expired",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Your payment session has timed out due to inactivity.\nWould you like to try again?",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,

                  ),

                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.red),
                        const SizedBox(width: 5),
                        Text(
                          "Auto-redirecting in ${snapshot.data} sec",
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogActive = false;
                    if (countdownTimer != null && countdownTimer!.isActive) {
                      countdownTimer!.cancel();
                    }

                    if (!countdownController.isClosed) {
                      countdownController.close();
                    }

                    try {
                      Navigator.of(context).pop();

                      if (mounted) {
                        Navigator.pushReplacement(
                          currentContext,
                          MaterialPageRoute(builder: (context) => const ImageCarousel()),
                        );
                      }
                    } catch (e) {
                      print("Navigation error: $e");
                      // Try alternative navigation if initial attempt fails
                      if (mounted) {
                        Future.microtask(() {
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(builder: (context) => const ImageCarousel()),
                          );
                        });
                      }
                    }
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    dialogActive = false;
                    if (countdownTimer != null && countdownTimer!.isActive) {
                      countdownTimer!.cancel();
                    }

                    if (!countdownController.isClosed) {
                      countdownController.close();
                    }

                    try {
                      Navigator.of(context).pop();
                      if (mounted) {
                        _generateQRCode(); // Regenerate the QR code
                      }
                    } catch (e) {
                      print("Navigation error: $e");
                      // Try QR code generation directly if navigation fails
                      if (mounted) {
                        Future.microtask(() {
                          _generateQRCode();
                        });
                      }
                    }
                  },
                  child: const Text(
                    "Try Again",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            );
          },
        );
      },
    ).then((_) {
      // This runs when dialog is closed
      dialogActive = false;
      countdownTimer?.cancel();
      if (!countdownController.isClosed) {
        countdownController.close();
      }
    });

    // Now start the countdown timer
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // First check if timer should still be running
      if (!dialogActive || !mounted) {
        timer.cancel();
        if (!countdownController.isClosed) {
          countdownController.close();
        }
        return;
      }

      dialogCountdown--;

      // Send the updated value to the stream
      if (!countdownController.isClosed) {
        countdownController.add(dialogCountdown);
      }

      if (dialogCountdown <= 0) {
        timer.cancel();
        dialogActive = false;

        // Close the stream
        if (!countdownController.isClosed) {
          countdownController.close();
        }

        // Pop the dialog if it's still showing
        try {
          if (dialogContext != null) {
            if (Navigator.of(dialogContext!, rootNavigator: true).canPop()) {
              Navigator.of(dialogContext!, rootNavigator: true).pop();
            }
          }

          // Navigate to ImageCarousel only if the widget is still mounted
          if (mounted) {
            Navigator.pushReplacement(
              currentContext,
              MaterialPageRoute(builder: (context) => const ImageCarousel()),
            );
          }
        } catch (e) {
          print("Navigation error during auto-redirect: $e");
          // Try alternative navigation approach
          if (mounted) {
            Future.microtask(() {
              Navigator.pushReplacement(
                currentContext,
                MaterialPageRoute(builder: (context) => const ImageCarousel()),
              );
            });
          }
        }
      }
    });
  }

  void showQRCodeDialog() {
    if (_qrCodeUrl != null) {
      // Store a reference to the current context that won't be invalidated
      final BuildContext currentContext = context;
      bool dialogActive = true;

      // Use a separate variable to track if dialog is still active
      Timer? dialogTimer;

      showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {

              // Start the timer after the dialog is shown
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  // First check if dialog is still active before doing anything
                  if (!dialogActive) {
                    timer.cancel();
                    return;
                  }

                  // Safe update of dialog state
                  if (dialogActive) {
                    setDialogState(() {
                      // Just trigger rebuild to show updated time
                    });
                  }

                  // Check if time has expired
                  if (_remainingSeconds <= 0) {
                    timer.cancel();
                    dialogActive = false;

                    // Use try-catch to handle any potential navigation errors
                    try {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(); // Close this dialog
                      }

                      // Only show expiration dialog if widget is still mounted
                      if (mounted) {
                        Future.delayed(Duration(milliseconds: 300), () {
                          if (mounted) {
                            _showExpirationDialogWithAutoNavigate();
                          }
                        });
                      }
                    } catch (e) {
                      print("Navigation error: $e");
                      // Skip further navigation if there's an error
                    }
                  }
                });
              });

              return PopScope(
                onPopInvoked: (didPop) {
                  // Mark dialog as inactive and cancel timer
                  dialogActive = false;
                  dialogTimer?.cancel();
                },
                child: Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // const Text(
                        //   'Scan to Pay',
                        //   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        // ),
                        // const SizedBox(height: 16),
                        Image.network(
                          _qrCodeUrl!,
                          width: 520,
                          height: 630,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 450,
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
                        //   style: TextStyle(fontSize: 12),
                        //   textAlign: TextAlign.center,
                        // ),

                        // Add countdown timer to main screen if QR is generated
                        if (_qrCodeUrl != null && !_isTimedOut) ...[
                          // const SizedBox(height: 15),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: Text(
                                'Payment expires in ${_formatTime(_remainingSeconds)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _remainingSeconds < 60 ? Colors.red : Colors.green.shade800,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // const SizedBox(height: 16),
                        // TextButton(
                        //   onPressed: () {
                        //     // Mark dialog as inactive before closing
                        //     dialogActive = false;
                        //     dialogTimer?.cancel();
                        //
                        //     // Try-catch for safer navigation
                        //     try {
                        //       Navigator.of(context).pop();
                        //     } catch (e) {
                        //       print("Error closing dialog: $e");
                        //     }
                        //   },
                        //   child: const Text(
                        //     "Close",
                        //     style: TextStyle(color: Colors.red, fontSize: 12),
                        //   ),
                        // ),
                        TextButton(
                          onPressed: () {
                            // Mark dialog as inactive before closing
                            dialogActive = false;
                            dialogTimer?.cancel();

                            // Try-catch for safer navigation
                            try {
                              Navigator.of(context).pop();
                            } catch (e) {
                              print("Error closing dialog: $e");
                            }
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ).then((_) {
        // This runs when the dialog is closed by any means
        dialogActive = false;
        dialogTimer?.cancel();
      });
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
        " Gynecologist": "2",
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


        // Start countdown timer when QR code is generated
        _startCountdownTimer();

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


  Future<void> _checkPaymentStatus() async {
    if (_qrCodeId == null) {
      _paymentCheckTimer?.cancel();
      print('QR Code ID is null, skipping request.');
      return;
    }

    try {
      // Direct request to check QR code payment status
      final response = await http.get(
        Uri.parse('https://api.razorpay.com/v1/payments/qr_codes/$_qrCodeId'),
        headers: {
          // Use basic auth with your API key (only include key_id in client code)
          //'Authorization': 'Basic ${base64Encode(utf8.encode('$RAZORPAY_KEY_ID:'))}',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$RAZORPAY_KEY_ID:$RAZORPAY_KEY_SECRET'))}',
          'Content-Type': 'application/json',
        },
      );
      print('QR Payment status response: ${response.statusCode}');
      print('QR Payment status body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if QR code status is closed and close_reason is paid
        if (data['status'] == 'closed' && data['close_reason'] == 'paid') {
          _paymentCheckTimer?.cancel();
          _handlePaymentSuccess();
          return;
        }

        // Alternative check for status
        if (data['status'] == 'paid' || data['status'] == 'used') {
          // QR code has been paid, now verify the payment details
          final payments = data['payments'];

          if (payments != null && payments.isNotEmpty) {
            // Check if any payment is successful
            for (var payment in payments) {
              if (payment['status'] == 'captured' || payment['status'] == 'authorized') {
                _paymentCheckTimer?.cancel();
                _paymentId = payment['id']; // Store the payment ID
                _handlePaymentSuccess();
                return;
              }
            }
          } else if (data['status'] == 'used') {
            // Some UPI payments might show as "used" before payment details appear
            _paymentCheckTimer?.cancel();
            _handlePaymentSuccess();
            return;
          } else if (data['status'] == 'used') {
            // Some UPI payments might show as "used" before payment details appear
            _paymentCheckTimer?.cancel();
            _handlePaymentSuccess();
            return;
          }
        }

        // If not paid yet, continue polling
      } else {
        print('Failed to check QR code status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during payment status check: ${e.toString()}');
    }
  }





  void _handlePaymentSuccess() {

     // Cancel countdown timer on successful payment
    _countdownTimer?.cancel();
    _paymentCheckTimer?.cancel();
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
                        // Add countdown timer to main screen if QR is generated
                        // if (_qrCodeUrl != null && !_isTimedOut) ...[
                        //   const SizedBox(height: 15),
                        //   Center(
                        //     child: Container(
                        //       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        //       child: Text(
                        //         'Payment expires in ${_formatTime(_remainingSeconds)}',
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //           color: _remainingSeconds < 60 ? Colors.red : Colors.green.shade800,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isTimedOut
                                    ? null  // Disable button if timed out
                                    : (_qrCodeUrl == null
                                    ? () => _generateQRCode()
                                    : () => showQRCodeDialog()), // Reopen QR Code Popup
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  disabledBackgroundColor: Colors.grey, // Grey when timed out
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  _isTimedOut
                                      ? 'Payment Time Out'
                                      : (_qrCodeUrl == null ? 'Generate Payment QR' : 'View QR Code'),
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




