import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../APIServices/base_api.dart';
import '../Paymentgetway/pay.dart';
import '../VideoCallDisaScreen/NoInternetScreen.dart';
import '../check connection/connectivityProvider.dart';
import '../screen_saver/screen_saveradd.dart';
import '../topSection/topsection.dart';
import 'package:url_launcher/url_launcher.dart';


// class OtpLoginScreen extends StatefulWidget {
//   final String speciality;
//   final String price;
//
//
//   const OtpLoginScreen({super.key,
//     required this.speciality, required this.price});
//
//   @override
//   _OtpLoginScreenState createState() => _OtpLoginScreenState();
// }
// class _OtpLoginScreenState extends State<OtpLoginScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   bool isLoading = false;
//
//
//   bool _isChecked = false;
//
//   void _showTermsDialog() async {
//     bool? result = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//
//         content: const SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               'By proceeding, I confirm that I am voluntarily opting for a telemedicine consultation.\n\n'
//                   'I understand that this consultation will be conducted via video conferencing with a Registered Medical Practitioner (RMP). '
//                   'I acknowledge the limitations of telemedicine, including the absence of a physical examination, and I consent to receive medical advice and prescriptions electronically.\n\n'
//                   'I am aware that my medical information will be kept confidential in accordance with applicable laws and regulations.',
//               style: TextStyle(fontSize: 16, height: 1.5),
//             ),
//           ),
//         ),
//         actions: [
//
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               elevation: 4,
//               backgroundColor: Colors.blue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () {
//               Navigator.of(context).pop(true);
//               Future.delayed(const Duration(milliseconds: 200), () {
//                 setState(() {
//                   _isChecked = true;
//                   _validate();
//                 });
//               });
//             },
//             child: const Text('Proceed to Consultation',style: TextStyle(color: Colors.white),),
//           ),
//         ],
//       ),
//     );
//
//     if (result != true) {
//       setState(() {
//         _isChecked = false;
//       });
//     }
//   }
//
//   void _validate() async {
//     if (!_isChecked) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please agree to the Terms and Conditions")),
//       );
//     } else {
//       await sendOtp(); // Make sure sendOtp() is async
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Consent Send: $_isChecked")),
//       );
//
//     }
//   }
//
//
//   Future<void> sendOtp() async {
//     final phoneNumber = phoneController.text.trim();
//     final name = nameController.text.trim();
//
//     var sessionBox = await Hive.openBox('sessionBox');
//     final sessionCookie = sessionBox.get('session_cookie');
//
//
//     final Map<String, String> headers = {
//       "Content-Type": "application/x-www-form-urlencoded",
//       if (sessionCookie != null) "Cookie": sessionCookie,
//     };
//
//     print(sessionCookie);
//
//     if (phoneNumber.isEmpty || phoneNumber.length != 10) {
//       showSnackbar('Enter a valid 10-digit phone number');
//       return;
//     }
//
//     if (!_isChecked) {
//       showSnackbar('Please accept the terms and conditions');
//       return;
//     }
//
//     setState(() => isLoading = true);
//     try {
//       final response = await http.post(
//         Uri.parse("$baseapi/tab/tab-signup"),
//         // Updated API endpoint
//         headers: {
//           "Content-Type": "application/x-www-form-urlencoded",
//           if (sessionCookie != null) "Cookie": sessionCookie,
//         },
//         body: {
//           "fullname": name,
//           "number": phoneNumber,
//           "user_type":"3",
//           "consent": _isChecked.toString(), // Send terms acceptance status
//         },
//       );
//
//       final data = jsonDecode(response.body);
//       print(response.body);
//       print("Response Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");
//
//
//       print("Sending consent: ${_isChecked.toString()}");
//       print("Consent checkbox is checked: $_isChecked");
//
//
//
//       // Store session cookie from response
//       String? setCookie = response.headers['set-cookie'];
//       if (setCookie != null) {
//         print("Storing session cookie: $setCookie");
//         await sessionBox.put('session_cookie', setCookie);
//       }
//
//       if (response.statusCode == 200) {
//
//         showSnackbar('OTP sent successfully');
//
//         // Navigate to OTP Verification Screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OtpVerificationScreen(
//               phoneNumber: phoneNumber,
//               speciality: widget.speciality,
//               price: widget.price,
//               name: name,
//             ),
//           ),
//         );
//       } else {
//         showSnackbar(data["message"] ?? 'Failed to send OTP');
//       }
//     } catch (e) {
//       showSnackbar('Error: ${e.toString()}');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
//     );
//   }
//
//   void _openTerms() async {
//     final Uri url = Uri.parse('https://bharatteleclinic.co/company/terms_condition');
//     if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//       throw Exception('Could not launch $url');
//     }
//   }
//
//   void _openPrivacy() async {
//     final Uri url = Uri.parse('https://bharatteleclinic.co/company/privacy');
//     if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//       throw Exception('Could not launch $url');
//     }
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // const SizedBox(height: 20,),
//               const TopSection(),
//               // const SizedBox(height: 20),
//               const Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Consult with Doctor",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         "Speciality",
//                         style: TextStyle(fontSize: 15),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.check_circle, color: Colors.blueAccent),
//                         const SizedBox(width: 10),
//                         Text(
//                           widget.speciality,
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       widget.price,
//                       style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: nameController,
//                 keyboardType: TextInputType.name,
//                 decoration: const InputDecoration(
//                   labelText: 'Patient Name',
//                   hintText: 'Enter patient name for prescription',
//                   hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
//                   floatingLabelBehavior: FloatingLabelBehavior.auto, // Label moves up on focus
//                   border: OutlineInputBorder(), // Optional: Adds a border
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue, width: 2), // Highlight on focus
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 1),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: const InputDecoration(
//                   labelText: 'Mobile Number',
//                   hintText: 'eg.0123456789',
//                   hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
//                   floatingLabelBehavior: FloatingLabelBehavior.auto, // Label moves up on focus
//                   border: OutlineInputBorder(), // Adds a border around the input
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue, width: 2), // Highlight on focus
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 1),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Checkbox(
//                     value: _isChecked,
//                     onChanged: (_) {
//                       _showTermsDialog(); // Optional
//                     },
//                     activeColor: Colors.black,
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Accept',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Wrap(
//                           children: [
//                             const Text(
//                               'By logging in, you agree to our ',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                             GestureDetector(
//                               onTap: _openTerms,
//                               child: const Text(
//                                 'Terms and Conditions',
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                             const Text(
//                               ' & ',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                             GestureDetector(
//                               onTap: _openPrivacy,
//                               child: const Text(
//                                 'Privacy Policy',
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Get OTP Button
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: isLoading ? null : _validate,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: isLoading
//                           ? const CircularProgressIndicator()
//                           : const Text(
//                         'Continue',
//                         style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 10), // Space between buttons
//                   // Cancel Button
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               title: const Text(
//                                 "Cancel Confirmation",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               content: const Text(
//                                 "Are you sure you want to cancel? Your progress will not be saved.",
//                                 style: TextStyle(color: Colors.black87),
//                               ),
//                               actions: [
//                                 /// **Stay Button**
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(), // Close dialog
//                                   child: const Text(
//                                     "Stay",
//                                     style: TextStyle(color: Colors.green, fontSize: 16),
//                                   ),
//                                 ),
//
//                                 /// **Confirm Cancel Button (Red Background)**
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.of(context).pop(); // Close dialog
//                                     Navigator.of(context).pop(); // Go back
//                                     Navigator.of(context).pop(); // Go back
//
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red, // **Red background**
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     "Cancel",
//                                     style: TextStyle(color: Colors.white, fontSize: 16),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white, // **Same as TextButton**
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//


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
  final TextEditingController ageController = TextEditingController();

  bool isLoading = false;
  bool _isChecked = false;
  String selectedGender = '';

  void _showTermsDialog() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'By proceeding, I confirm that I am voluntarily opting for a telemedicine consultation.\n\n'
                  'I understand that this consultation will be conducted via video conferencing with a Registered Medical Practitioner (RMP). '
                  'I acknowledge the limitations of telemedicine, including the absence of a physical examination, and I consent to receive medical advice and prescriptions electronically.\n\n'
                  'I am aware that my medical information will be kept confidential in accordance with applicable laws and regulations.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  _isChecked = true;
                  _validate();
                });
              });
            },
            child: const Text('Proceed to Consultation',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );

    if (result != true) {
      setState(() {
        _isChecked = false;
      });
    }
  }

  void _validate() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms and Conditions")),
      );
    } else {
      await sendOtp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Consent Send: $_isChecked")),
      );
    }
  }

  Future<void> sendOtp() async {
    final phoneNumber = phoneController.text.trim();
    final name = nameController.text.trim();
    final age = ageController.text.trim();

    var sessionBox = await Hive.openBox('sessionBox');
    final sessionCookie = sessionBox.get('session_cookie');

    // Validation
    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      showSnackbar('Enter a valid 10-digit phone number');
      return;
    }

    if (name.isEmpty) {
      showSnackbar('Please enter patient name');
      return;
    }

    if (age.isEmpty || int.tryParse(age) == null || int.parse(age) < 1 || int.parse(age) > 120) {
      showSnackbar('Please enter a valid age (1-120)');
      return;
    }

    if (selectedGender.isEmpty) {
      showSnackbar('Please select gender');
      return;
    }

    if (!_isChecked) {
      showSnackbar('Please accept the terms and conditions');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseapi/tab/tab-signup"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          if (sessionCookie != null) "Cookie": sessionCookie,
        },
        body: {
          "fullname": name,
          "number": phoneNumber,
          "user_type": "3",
          "age": age,
          "gender": selectedGender.toLowerCase(),
          "consent": _isChecked.toString(),
        },
      );

      final data = jsonDecode(response.body);
      print(response.body);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");



    print("----- 📤 SENDING OTP REQUEST -----");
    print("➡️ URL: $baseapi/tab/tab-signup");
    print("----- 📥 RESPONSE RECEIVED -----");
    print("⬅️ Status Code: ${response.statusCode}");
    print("⬅️ Headers: ${response.headers}");
    debugPrint("⬅️ Body: ${response.body}", wrapWidth: 1024);




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

  void _openTerms() async {
    final Uri url = Uri.parse('https://bharatteleclinic.co/company/terms_condition');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  void _openPrivacy() async {
    final Uri url = Uri.parse('https://bharatteleclinic.co/company/privacy');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
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
              const TopSection(),
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
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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

              // Patient Name Field
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  hintText: 'Enter patient name for prescription',
                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Mobile Number Field
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'eg.0123456789',
                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Age and Gender Row
              Row(
                children: [
                  // Age Field
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter age',
                        hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Gender Dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedGender.isEmpty ? null : selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      hint: const Text(
                        'Select Gender',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      items: ['Male', 'Female', 'Other'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue ?? '';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Terms and Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (_) {
                      _showTermsDialog();
                    },
                    activeColor: Colors.black,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          children: [
                            const Text(
                              'By logging in, you agree to our ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: _openTerms,
                              child: const Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              ' & ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: _openPrivacy,
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Continue and Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Continue Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _validate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
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

  void showDialogBox(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notification"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkDoctorAvailability(String token, String specialityId) async {
    try {
      final Uri apiUrl = Uri.parse("$baseapi/tab/is_speciality_doctors_available");

      Map<String?, String?> specialityMapping = {
        "General Physician": "1",
        " Gynecologist": "2",
        "Dermatologist": "3",
        "Sexologist": "4",
        "Psychiatrist": "5",
        "Gastroenterologist": "6",
        "Pediatrician": "7",
        "ENT Specialist": "8",
        "Urologist": "9",
        "Orthopedist": "10",
        "Neurologist": "11",
        "Cardiologist": "12",
        "Nutritionist/Dietitian": "13",
        "Diabetology": "14",
        "Eye & Vision": "15",
        "Dentist": "16",
        "Pulmonologist": "17",
        "Ayurveda": "18",
        "Homeopathy": "19",
        "Cancer": "20",
        "Physiotherapist": "21",
        "Nephrologist": "22",
        "Trichologist": "23",
      };

      final Map<String?, String?> requestBody = {
        "speciality_id": specialityMapping[specialityId],
      };

      print("API URL: $apiUrl");
      print("Request Body: $requestBody");

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $token",
        },
        body: requestBody,
      );

      print("Doctor Availability Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["error"] == null) {
        bool isAvailable = data["consultations_available"] ?? false;

        if (isAvailable) {
          showSnackbar("Doctor is available!");
        } else {
          showSnackbar("No doctors available. try another...");

          /// **Delay to allow snackbar to appear before navigation**
          if (isAvailable) {
            showDialogBox("Doctor is available!");
          } else {
            showDialogBox("No doctors available. Try another...");

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                navigateToNoDoctorScreen();
              }
            });
          }

        }
      } else {
        showSnackbar("Error: ${data["message"] ?? "Invalid response"}");
      }
    } catch (e) {
      showSnackbar("checking doctor availability: ${e.toString()}");
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          navigateToNoDoctorScreen();
        }
      });

    }
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




      print("📤 Starting OTP Verification Request");
      print("➡️ Endpoint: $apiUrl");
      print("➡️ Entered OTP: $otp");



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



      print("📦 Request Headers: $headers");
      print("📦 Request Body: $body");


      final response = await http.post(
        apiUrl,
        headers: headers,
        body: body,
      );


      print("📥 Response Received:");
      print("⬅️ Status Code: ${response.statusCode}");
      debugPrint("⬅️ Body: ${response.body}", wrapWidth: 1024);
      print("⬅️ Headers: ${response.headers}");


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


          print("✅ OTP Verified Successfully!");
          print("🔐 Access Token: $token");
          print("🆔 Token ID: $tokenId");


          var userBox = await Hive.openBox('userBox');
          await userBox.put('authToken', token);
          await userBox.put('tokenId', tokenId);  // Store token_id


          final dataa = jsonDecode(response.body);
          print(dataa);
          print(response.body);
          print("Response Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}");

          if (mounted) {
            await checkDoctorAvailability(token, widget.speciality);  // Call availability check
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => pay(
                name: widget.name,
                phoneNumber: widget.phoneNumber,
                token: token,
                price:widget.price,
                specialityId: '',


              ),),
            );
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


  void navigateToNoDoctorScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoDoctorScreen()),
      );
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
                    icon: const Icon(Icons.close,color: Colors.red,),
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
                    child: const Text("Get via Call", style: TextStyle(color: Colors.indigo,fontSize: 12)),

                  ),
                  TextButton(
                    onPressed: canResendOtp ? resendOtp : null,
                    child: Text(
                      canResendOtp ? "Resend OTP" : "Resend OTP $countdownSeconds sec",
                      style: TextStyle(
                          color: canResendOtp ? Colors.blue : Colors.grey,fontSize: 12
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














// **Screen for when no doctor is available**
class NoDoctorScreen extends StatefulWidget {
  const NoDoctorScreen({super.key});

  @override
  _NoDoctorScreenState createState() => _NoDoctorScreenState();
}
class _NoDoctorScreenState extends State<NoDoctorScreen> {
  int countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        _timer?.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ImageCarousel()));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 60),
              const SizedBox(height: 20),
              const Text(
                "Doctor Unavailable",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Currently, this specialty doctor is not available.\n\n"
                    "We apologize for the inconvenience. You can wait a moment or contact our support team for assistance.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                "Redirecting in $countdown seconds...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}