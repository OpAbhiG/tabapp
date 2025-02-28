import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Connecting_screen/ConnectingScreen.dart';
import '../topSection/topsection.dart';

class pay extends StatefulWidget {
  final String token;
  final String name;
  final String phoneNumber;
  final String price;

  const pay({super.key,
    required this.token, required this.name, required this.phoneNumber, required this.price
  });
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}
class _PaymentScreenState extends State<pay> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  }

  // void _makePayment() {
  //   int amountInPaise = (double.parse(widget.price) * 100).toInt(); // Convert to paise
  //
  //   var options = {
  //
  //     'key': 'rzp_test_USRnc9D0LcPYTb', // Replace with your Razorpay key
  //     'amount': amountInPaise, // Amount in paise (e.g., 1000 = ₹10)
  //     'name': "hello",
  //     'description': 'Doctor Consultation Fees',
  //     'prefill': {
  //       'contact': "welcome",
  //       'email': 'bharat@example.com',
  //     },
  //     'theme': {'color': '#3399cc'},
  //   };
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
//v2
  void _makePayment() {
    int amountInPaise = (double.parse(widget.price) * 100).toInt(); // Convert to paise

    var options = {
      'key': 'rzp_test_USRnc9D0LcPYTb', // Replace with your Razorpay key
      'amount': amountInPaise, // Amount in paise (e.g., 1000 = ₹10)
      'currency': 'INR',
      'name': "hello",
      'description': 'Doctor Consultation Fees',
      'prefill': {
        'contact': widget.phoneNumber,
        'email': 'bharat@example.com',
      },
      'theme': {'color': '#3399cc'},
      'method': {
        'qr': true // This will enable only QR Code payment
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }



  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful: ${response.paymentId}")));

    Future.delayed(const Duration(seconds: 0), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConnectingScreen(

          token: widget.token,
        )),
      );
    }
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
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
                          const TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          // const SizedBox(height: 15),
                          // Row(
                          //   children: [
                          //     const Expanded(
                          //       child: TextField(
                          //         decoration: InputDecoration(
                          //           hintText: 'Enter coupon code',
                          //           border: OutlineInputBorder(),
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 8),
                          //     ElevatedButton(
                          //       onPressed: () {},
                          //       style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.grey[300],
                          //         padding: const EdgeInsets.symmetric(horizontal: 15),
                          //       ),
                          //       child: const Text(
                          //         'Apply',
                          //         style: TextStyle(color: Colors.black),
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _makePayment();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text(
                                    'Continue to payment',
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
                                          /// **Stay Button**
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(), // Close dialog
                                            child: const Text(
                                              "Stay",
                                              style: TextStyle(color: Colors.green, fontSize: 16),
                                            ),
                                          ),

                                          /// **Confirm Cancel Button**
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close confirmation dialog
                                              Navigator.of(context).pop(); // Go back
                                              Navigator.of(context).pop(); // Close confirmation dialog
                                              Navigator.of(context).pop(); // Go back
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red, // Red cancel button
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
            )

        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();

  }
}
