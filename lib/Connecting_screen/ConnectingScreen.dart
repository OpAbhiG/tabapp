import 'dart:convert';
import 'dart:math'; // Import for max() function
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../APIServices/base_api.dart';
import '../VideoCall/call_page.dart';
import '../VideoCall/video_call_screen.dart';
import '../main.dart';

class ConnectingScreen extends StatefulWidget {
  final String token;
  // final String price;
  const ConnectingScreen({super.key,
    required this.token,
    // required this.price

  });
  @override
  _ConnectingScreenState createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  String errorMessage='';

  Future<void> _printFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM TOKEN: $token");
    } catch (e) {
      debugPrint("Error getting FCM token:$e");
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      print("[LOCATION] Checking location services...");
      bool serviceEnabled = await _geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("[LOCATION ERROR] Location services disabled");
        throw 'Location services are disabled';
      }
      print("[LOCATION] Checking permissions...");
      LocationPermission permission = await _geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print("[LOCATION ERROR] Permissions denied");

        permission = await _geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }
      final position = await _geolocator.getCurrentPosition();

      print("[LOCATION SUCCESS] Position acquired: "
          "${position.latitude}, ${position.longitude}");

      return position;

    } catch (e) {
      print("[LOCATION CRITICAL ERROR] $e");
      setState(() => errorMessage = e.toString());
      return null;
    }
  }

  Future<void> _sendFCMTokenToBackend() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        print("[FCM ERROR] No FCM token available");
        return;
      }

      // Retrieve token_id from Hive storage
      var userBox = await Hive.openBox('userBox');
      int? tokenId = userBox.get('tokenId');  // Fetch stored token_id

      if (tokenId == null) {
        print("[FCM ERROR] No token_id found in storage");
        return;
      }

      print("[FCM] Sending token and token_id to backend...");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseapi/user/fcm"),
      );

      // Add form data
      request.fields['fcm_token'] = fcmToken;
      request.fields['token_id'] = tokenId.toString(); // Send token_id

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print("[FCM RESPONSE] Status: ${response.statusCode}");
      print("[FCM RESPONSE] Body: $responseData");

      if (response.statusCode == 200) {
        print("[FCM SUCCESS] Token saved successfully");
      } else {
        print("[FCM ERROR] Failed to save token: $responseData");
      }
    } catch (e) {
      print("[FCM CRITICAL ERROR] $e");
    }
  }


  String? sessionId='';
  String? meetingId='';
  Future<void> _getSessionId() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseapi/tab/requestmoney-tb"),
      );

      request.fields['token'] = widget.token;
      request.fields['speciality_id'] = '1';
      request.headers['Authorization'] = 'Bearer ${widget.token}';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("[SESSION RESPONSE] Status: ${response.statusCode}");
      print("[SESSION RESPONSE] Body: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);

        if (jsonResponse.containsKey('session_id') && jsonResponse['session_id'] != null) {
          sessionId = jsonResponse['session_id'].toString(); // ✅ Convert to String

          print("[SESSION SUCCESS] Session ID: $sessionId");

          // ✅ Ensure sessionId is valid before calling _requestConsultation
          _requestConsultation(sessionId!);
        } else {
          print("[SESSION ERROR] session_id is missing in response!");
        }
      } else {
        print("[SESSION ERROR] Failed to get session ID: $responseData");
      }
    } catch (e) {
      print("[SESSION CRITICAL ERROR] $e");
    }
  }


  Future<void> _requestConsultation(String sessionId) async {
    if (sessionId.isEmpty) {
      print("[CONSULTATION ERROR] session_id is empty!");
      return;
    }

    try {
      Position? position = await _getCurrentLocation();
      if (position == null) {
        print("[LOCATION ERROR] Unable to get current location");
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseapi/patient/request_consultation"),
      );

      request.fields['latitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
      request.fields['speciality'] = '1';
      request.fields['session_id'] = sessionId;

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("[CONSULTATION RESPONSE] Status: ${response.statusCode}");
      print("[CONSULTATION RESPONSE] Body: $responseData");

      var jsonResponse = jsonDecode(responseData);

      print("[DEBUG] Sending session_id: $sessionId");
      print("[DEBUG] Latitude: ${position.latitude}");
      print("[DEBUG] Longitude: ${position.longitude}");
      print("[DEBUG] Speciality: 1");

      if (response.statusCode == 200) {
        if (jsonResponse.containsKey('meeting_id')) {
          String meetingId = jsonResponse['meeting_id'];
          print("[CONSULTATION SUCCESS] Meeting ID: $meetingId");

          // _checkDoctorResponse(meetingId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallPage(
                localUserId: localUserID, // Replace with actual user ID
                id: meetingId
              ),
            ),
          );



        } else {
          print("[CONSULTATION ERROR] meeting_id not found in response!");
        }
      } else {
        print("[CONSULTATION ERROR] $responseData");
      }
    } catch (e) {
      print("[CONSULTATION CRITICAL ERROR] $e");
    }
  }

////////waiting code for doctor response
  // Future<void> _checkDoctorResponse(String meetingId) async {
  //   const int maxRetries = 20;  // Maximum times to check
  //   int retryCount = 0;
  //   const Duration checkInterval = Duration(seconds: 5); // Check every 5 sec
  //
  //   while (retryCount < maxRetries) {
  //     await Future.delayed(checkInterval); // Wait before checking again
  //
  //     try {
  //       var response = await http.get(
  //         Uri.parse("$baseapi/patient/request_consultation?meeting_id=$meetingId"),
  //         headers: {
  //           'Authorization': 'Bearer ${widget.token}',
  //         },
  //       );
  //
  //       if (response.statusCode == 200) {
  //         var jsonResponse = jsonDecode(response.body);
  //
  //         if (jsonResponse.containsKey('status')) {
  //           String status = jsonResponse['status'];
  //
  //           if (status == "accepted") {
  //             print("[CALL ACCEPTED] Starting video call...");
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => VideoCallScreen(
  //                   appointmentId: meetingId,
  //                 ),
  //               ),
  //             );
  //             return; // Exit loop after call starts
  //           } else if (status == "rejected") {
  //             print("[CALL REJECTED] Doctor declined the call.");
  //             setState(() {
  //               errorMessage = "Doctor is unavailable. Please try later.";
  //             });
  //             return;
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       print("[CHECK RESPONSE ERROR] $e");
  //     }
  //
  //     retryCount++;
  //   }
  //
  //   print("[TIMEOUT] No response from doctor.");
  //   setState(() {
  //     errorMessage = "No response from doctor.";
  //   });
  // }


  /////without waiting dr i start vcall

  Future<void> _checkDoctorResponse(String meetingId) async {
    try {
      var response = await http.get(
        Uri.parse("$baseapi/patient/request_consultation?meeting_id=$meetingId"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('status')) {
          String status = jsonResponse['status'];

          if (status == "accepted" || status == "pending") {
            print("[CALL ACCEPTED/PENDING] Entering video call...");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallPage(
                    localUserId: localUserID, // Replace with actual user ID
                    id: meetingId
                ),
              ),
            );
            return;
          } else if (status == "rejected") {
            print("[CALL REJECTED] Doctor declined the call.");
            setState(() {
              errorMessage = "Doctor is unavailable. Please try later.";
            });
          }
        }
      }
    } catch (e) {
      print("[CHECK RESPONSE ERROR] $e");
      setState(() {
        errorMessage = "Error connecting to server.";
      });
    }
  }




  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _getCurrentLocation();
    _printFCMToken();  // Call function to print token
    _sendFCMTokenToBackend();
    _checkDoctorResponse(meetingId!);
    // _requestConsultation();

    _getSessionId();
    _requestConsultation(sessionId!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding circles (Radar Effect)
              for (int i = 0; i < 3; i++)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value =
                    (_controller.value - (i * 0.3)).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: max(0, 1 - value),
                      child: Container(
                        width: screenWidth * 0.2 + (value * screenWidth * 0.7),
                        height: screenWidth * 0.2 + (value * screenWidth * 0.7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Centered content (Text → Image → Text)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Searching" text
                  Text(
                    'Searching',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.09), // Maintained spacing

                  // Stethoscope Image
                  Image.asset(
                    'assets/doctor/stethoscope.png',
                    width: screenWidth * 0.15, // Maintained original size
                  ),
                  SizedBox(height: screenHeight * 0.07), // Maintained spacing

                  // Success Message
                  Text(
                    'Your payment is successful!\nFinding you the best available doctor...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      color: Colors.grey[700],
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


// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: SafeArea(
//       child: Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Radar Animation Circles
//             for (double radius in [100, 140, 180])
//               AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return Container(
//                     width: radius,
//                     height: radius,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.blue.withOpacity(
//                         (1 - _controller.value).clamp(0, 1),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 120,),
//                 Icon(
//                   Icons.video_call,
//                   size: 50,
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 // const CircularProgressIndicator(),
//                 const SizedBox(height: 100),
//                 const Text(
//                   'Searching available Doctor...',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             // ),
//           ],
//         ),
//       ),
//     ),
//   );
// }