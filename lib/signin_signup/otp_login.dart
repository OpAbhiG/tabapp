import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tablet_degim/ApiServices/base_api.dart';
// import 'package:tablet_degim/Connecting_screen/ConnectingScreen.dart';
import '../APIServices/base_api.dart';
import '../Paymentgetway/pay.dart';
import '../topSection/topsection.dart';


class OtpLoginScreen extends StatefulWidget {
  final String speciality;
  final String price;

  const OtpLoginScreen({super.key,
    required this.speciality, required this.price});

  @override
  _OtpLoginScreenState createState() => _OtpLoginScreenState();
}
class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  Future<void> sendOtp() async {
    final phoneNumber = phoneController.text.trim();
    final name = nameController.text.trim();

    var sessionBox = await Hive.openBox('sessionBox');
    final sessionCookie = sessionBox.get('session_cookie');


    final Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      if (sessionCookie != null) "Cookie": sessionCookie,
    };

    print(sessionCookie);

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      showSnackbar('Enter a valid 10-digit phone number');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseapi/tab/tab-signup"), // Updated API endpoint
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          if (sessionCookie != null) "Cookie": sessionCookie,
        },
        body: {
          "fullname": name,
          "number": phoneNumber,
          "user_type":"3",
        },
      );

      final data = jsonDecode(response.body);
      print(response.body);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");


      // Store session cookie from response
      String? setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        print("Storing session cookie: $setCookie");
        await sessionBox.put('session_cookie', setCookie);
      }

      if (response.statusCode == 200) {
        showSnackbar('OTP sent successfully');

        // Navigate to OTP Verification Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: phoneNumber,
              speciality: widget.speciality,
              price: widget.price,
              name: name,
            ),
          ),
        );
      } else {
        showSnackbar(data["message"] ?? 'Failed to send OTP');
      }
    } catch (e) {
      showSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20,),
              const TopSection(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Consult with Doctor",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Speciality",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Text(
                          widget.speciality,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                        ),
                      ],
                    ),
                    Text(
                      widget.price,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  hintText: 'Enter patient name for prescription',
                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.auto, // Label moves up on focus
                  border: OutlineInputBorder(), // Optional: Adds a border
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2), // Highlight on focus
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'eg.0123456789',
                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.auto, // Label moves up on focus
                  border: OutlineInputBorder(), // Adds a border around the input
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2), // Highlight on focus
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "A Verification code will be send to this number.",
                  style: TextStyle(fontSize: 12,color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Get OTP Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10), // Space between buttons
                  // Cancel Button
                  Expanded(
                    child: ElevatedButton(
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

                                /// **Confirm Cancel Button (Red Background)**
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                    Navigator.of(context).pop(); // Go back
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // **Red background**
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // **Same as TextButton**
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}




class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String speciality;
  final String price;
  final String name;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.speciality,
    required this.price,
    required this.name,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}
class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool canResendOtp = false;
  int countdownSeconds = 60;
  Timer? countdownTimer;

  late final Box _userBox;


  @override
  void initState() {
    super.initState();
    startCountdown();
    _userBox = Hive.box('userBox');

  }

  void startCountdown() {
    setState(() => canResendOtp = false);
    countdownTimer?.cancel();
    countdownSeconds = 60;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 0) {
        setState(() => countdownSeconds--);
      } else {
        timer.cancel();
        setState(() => canResendOtp = true);
      }
    });
  }


  Future<void> resendOtp() async {
    setState(() => isLoading = true);
    try {
      print("inside try");
      final response = await http.post(
        Uri.parse("$baseapi/tab/tab-signup"), // Updated API endpoint
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "fullname": widget.name,  // Use the name from widget
          "number": widget.phoneNumber, // Phone number from widget
          "user_type": "3", // Updated parameter name
        },
      );

      final data = jsonDecode(response.body);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 && data["message"] == "OTP sent successfully!") {
        showSnackbar('OTP sent successfully');
        startCountdown(); // Restart OTP timer
      } else {
        showSnackbar(data["message"] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      showSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      showSnackbar('Enter a valid 6-digit OTP');
      return;
    }

    setState(() => isLoading = true);

    try {
      final Uri apiUrl = Uri.parse("$baseapi/tab/verify-otp");

      // Retrieve stored session cookie using Hive
      var sessionBox = await Hive.openBox('sessionBox');
      final sessionCookie = sessionBox.get('session_cookie');
      print("Stored Session Cookie: $sessionCookie");

      final Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        if (sessionCookie != null) "Cookie": sessionCookie,
      };

      final Map<String, String> body = {
        "otp": otp,
      };

      final response = await http.post(
        apiUrl,
        headers: headers,
        body: body,
      );

      // Store session cookie from response if present
      String? setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        await sessionBox.put('session_cookie', setCookie);
      }

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 400) {
        showSnackbar(data["error"] ?? "Verification failed");
        return;
      }

      if (response.statusCode == 401) {
        showSnackbar("Session expired. Please log in again.");
        return;
      }

      if (response.statusCode == 200) {
        if (data.containsKey("access_token") && data.containsKey("token_id")) {
          String token = data["access_token"];
          int tokenId = data["token_id"];

          var userBox = await Hive.openBox('userBox');
          await userBox.put('authToken', token);
          await userBox.put('tokenId', tokenId);  // Store token_id

          print("Token Stored: $token");
          print("Token ID Stored: $tokenId");

          if (mounted) {
////////////////////////////this payment screen open
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => pay(
                name: widget.name,
                phoneNumber: widget.phoneNumber,
                  token: token,
                  price:widget.price

              )),
            );

            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => ConnectingScreen(
            //     token: token,
            //   ),
            //   ),
            // );
          }
        } else {
          showSnackbar("OTP verification failed: Missing access token or token_id");
        }
      } else {
        showSnackbar(data["message"] ?? "Verification failed (${response.statusCode})");
      }
    } catch (e) {
      showSnackbar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// **Title Row with Close Button**
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Are you sure?",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.grey),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close dialog
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  /// **Message Text**
                                  const Text(
                                    "If you leave now, the information you have entered will be lost.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 20),

                                  /// **Full-Width Quit Button**
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                        Navigator.of(context).pop(); // Navigate back
                                        Navigator.of(context).pop(); // Navigate back
                                        Navigator.of(context).pop(); // Navigate back
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red, // Button color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: const Text(
                                        "Yes, Quit",
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text("We have sent an OTP on ", style: TextStyle(fontSize: 14,color: Colors.black)),
                ],
              ),
              Row(
                children: [
                  const Text("+91", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black)),
                  Text(widget.phoneNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black)),
                  const SizedBox(width: 5),
                  const Icon(Icons.edit, size: 18,color: Colors.black,)
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Get via Call", style: TextStyle(color: Colors.indigo)),

                  ),
                  TextButton(
                    onPressed: canResendOtp ? resendOtp : null,
                    child: Text(
                      canResendOtp ? "Resend OTP" : "Resend OTP in $countdownSeconds sec",
                      style: TextStyle(
                        color: canResendOtp ? Colors.blue : Colors.grey,
                        // decoration: TextDecoration.underline, // Adds underline
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child:
                ElevatedButton(
                  onPressed: isLoading ? null : verifyOtp, // ✅ Calls verifyOtp()
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text(
                    "Login",
                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }
}
