import 'dart:async';
import 'dart:convert';
import 'dart:math'; // Import for max() function
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../APIServices/base_api.dart';
import '../VideoCall/call_page.dart';
import '../main.dart';
import '../screen_saver/screen_saveradd.dart';

class ConnectingScreen extends StatefulWidget {
  final String token;
  final String speciality;

  const ConnectingScreen({
    super.key,
    required this.token,
    required this.speciality,
  });

  @override
  _ConnectingScreenState createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _quoteIndex = 0;
  final List<String> quotes = [
    "Thank you for your patience\n",
    "A doctor will be with you shortly\n",
    "We're experiencing a slight delay\nYou'll be connected soon\n",
    "Our doctors are attending to other patients.\nPlease hold on a little longer\n",
    "We apologize for the wait.\n",
    "Your health is our priority.\nThank you for understanding",
    "You're in the queue",
  ];

  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  String errorMessage = '';
  String? sessionId = '';
  String? meetingId = '';
  bool isExpired = false;
  int waitButtonClicks = 0;
  DateTime? lastWaitClickTime;
  final int maxWaitAttempts = 5;
  Timer? statusCheckTimer;

  // Map to track status states
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start a timer to change the quote every 2 seconds
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % quotes.length;
        });
      }
    });

    _initializeConsultation();
  }

  // Combined initialization function
  Future<void> _initializeConsultation() async {
    await _getCurrentLocation();
    await _printFCMToken();
    await _sendFCMTokenToBackend();
    await _getSessionId(); // This will call _requestConsultation when session ID is ready

    // Start periodic status check timer
    statusCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (sessionId != null && sessionId!.isNotEmpty) {
        _checkConsultationStatus(sessionId!);
      }
    });
  }

  // Function to check consultation status - this is the key new function///try this now
  Future<void> _checkConsultationStatus(String sessionId) async {
    if (sessionId.isEmpty) {
      print("[STATUS ERROR] session_id is empty!");
      return;
    }

    try {
      var response = await http.get(
        Uri.parse("$baseapi/patient/request_consultation_status?session_id=$sessionId"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print("[STATUS RESPONSE] Status code: ${response.statusCode}");
      print("[STATUS RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('status')) {
          String status = jsonResponse['status'];
          print("[STATUS] Current status: $status");

          // Handle different statuses
          switch (status) {
            case "pending":
            // Already showing waiting screen, just update time if available
              if (jsonResponse.containsKey('time_remaining_seconds')) {
                int timeRemaining = jsonResponse['time_remaining_seconds'] ?? 0;
                print("[STATUS] Time remaining: $timeRemaining seconds");

                if (mounted) {
                  setState(() {
                    errorMessage = "Session: $status\nTime remaining: $timeRemaining seconds";
                  });
                }
              } else {
                if (mounted) {
                  setState(() {
                    errorMessage = "Status: $status";
                  });
                }
              }
              break;

            case "accepted":
            // Doctor accepted - navigate to video call
              if (jsonResponse.containsKey('meeting_id') &&
                  jsonResponse.containsKey('accepted_doctor_id')) {
                meetingId = jsonResponse['meeting_id'];
                print("[STATUS SUCCESS] Accepted by doctor. Meeting ID: $meetingId");

                // Navigate to call screen
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallPage(
                        localUserId: localUserID,
                        id: meetingId!,
                        sessionid: sessionId,
                        token: widget.token,
                      ),
                    ),
                  );
                }
                // Stop checking status once we're in a call
                statusCheckTimer?.cancel();
              }
              break;

            case "expired":
            // Request expired - show support options
              print("[STATUS] Consultation request expired");
              if (mounted && !isExpired) {
                setState(() {
                  isExpired = true; // Show expired UI
                });
              }
              break;

            default:
              print("[STATUS ERROR] Unknown status: $status");
              if (mounted) {
                setState(() {
                  errorMessage = "Something went wrong with your consultation request.";
                });
              }
              break;
          }
        }
      } else {
        print("[STATUS ERROR] Failed to get status: ${response.body}");
        if (mounted) {
          setState(() {
            errorMessage = "connecting to server.";
          });
        }
      }
    } catch (e) {
      print("[STATUS CRITICAL ERROR] $e");
      if (mounted) {
        setState(() {
          errorMessage = "connecting to server.";
        });
      }
    }
  }

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
      if (mounted) {
        setState(() => errorMessage = e.toString());
      }
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

  Future<void> _getSessionId() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseapi/tab/requestmoney-tb"),
      );

      request.fields['token'] = widget.token;

      String mappedSpecialityId = specialityMapping[widget.speciality] ?? "1";
      request.fields['speciality_id'] = mappedSpecialityId;

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("[SESSION RESPONSE] Status: ${response.statusCode}");
      print("[SESSION RESPONSE] Body: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);

        if (jsonResponse.containsKey('session_id') && jsonResponse['session_id'] != null) {
          setState(() {
            sessionId = jsonResponse['session_id'].toString();
          });

          print("[SESSION SUCCESS] Session ID: $sessionId");

          // Request consultation with the session ID
          if (sessionId != null && sessionId!.isNotEmpty) {
            _requestConsultation(sessionId!);
          }
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

  // this 2nd i need to call
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
      request.fields['speciality'] = widget.speciality;

      String mappedSpecialityId = specialityMapping[widget.speciality] ?? "1";
      request.fields['speciality_id'] = mappedSpecialityId;
      request.fields['session_id'] = sessionId;

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("[CONSULTATION RESPONSE] Status: ${response.statusCode}");
      print("[CONSULTATION RESPONSE] Body: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        // Start checking status immediately after requesting consultation
        _checkConsultationStatus(sessionId);
      } else {
        print("[CONSULTATION ERROR] $responseData");
      }
    } catch (e) {
      print("[CONSULTATION CRITICAL ERROR] $e");
    }
  }

  // Handle Wait button click
  void _handleWaitButtonClick() async {
    final now = DateTime.now();

    // Check if 5 minutes (300 seconds) have passed since last click
    if (lastWaitClickTime != null) {
      final difference = now.difference(lastWaitClickTime!).inSeconds;
      if (difference >= 300) {
        // Reset count after 5 minutes
        waitButtonClicks = 0;
      }
    }

    // Update last click time and increment counter
    lastWaitClickTime = now;
    waitButtonClicks++;

    if (waitButtonClicks <= maxWaitAttempts) {
      // Reset UI
      setState(() {
        isExpired = false; // Hide expired UI
        errorMessage = "Searching for available doctors...";
        sessionId = null; // Clear existing session ID
      });

      // Generate new session ID
      await _getSessionId(); // This will also call _requestConsultation with the new session ID

      // Start checking status for the new session
      if (sessionId != null && sessionId!.isNotEmpty) {
        _checkConsultationStatus(sessionId!);
      }
    } else {
      // Reached maximum attempts
      setState(() {
        errorMessage = "Maximum wait attempts reached. Please contact support.";
      });

      // Redirect to support after 2 seconds
      Timer(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SupportScreen(token: widget.token, sessionid: sessionId!,),
            ),
          );
        }
      });
    }
  }
  // Navigate to support
  void _navigateToSupport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(token: widget.token, sessionid: sessionId!,),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Show different UI based on status
            if (isExpired)
            // Expired status UI with Wait and Support buttons
              _buildExpiredUI(screenWidth, screenHeight)
            else
            // Default searching UI
              _buildSearchingUI(screenWidth, screenHeight),

            // Error message overlay if needed
            if (errorMessage.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // UI for when session is expired
  Widget _buildExpiredUI(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off,
            size: 80,
            color: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            "Session Expired",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "We apologize for the delay.\nWould you like to wait a little longer or connect with our support team for assistance?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _handleWaitButtonClick,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  "Wait",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _navigateToSupport,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  "Connect to Support",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (waitButtonClicks > 0)
            Text(
              "Wait attempts: $waitButtonClicks/$maxWaitAttempts",
              style: TextStyle(
                color: waitButtonClicks >= maxWaitAttempts ? Colors.red : Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  // UI for searching (unchanged from your original)
  Widget _buildSearchingUI(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Centered radar animation
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding circles (Radar Effect)
              for (int i = 0; i < 3; i++)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value = (_controller.value - (i * 0.3)).clamp(0.0, 1.0);
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

              // Stethoscope Image
              Center(
                child: Image.asset(
                  'assets/stethoscope.png',
                  width: screenWidth * 0.15,
                ),
              ),
            ],
          ),
        ),

        // "Searching" text
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.15),
            child: Text(
              'Searching',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // Quotes
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.15),
            child: Container(
              width: screenWidth * 0.8,
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.08,
                maxHeight: screenHeight * 0.20,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < quotes.length; i++)
                    AnimatedOpacity(
                      opacity: _quoteIndex == i ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 800),
                      child: Container(
                        width: screenWidth * 0.8,
                        child: Text(
                          quotes[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.blueGrey,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}





class SupportScreen extends StatefulWidget {
  final String token;
  final String sessionid;

  const SupportScreen({Key? key, required this.token,
  required this.sessionid
  }) : super(key: key);

  @override
  _SupportScreenState createState() => _SupportScreenState();
}
class _SupportScreenState extends State<SupportScreen> {
  int _secondsRemaining = 7;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Start countdown timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        // Navigate to ImageCarousel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ImageCarousel(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String sid=widget.sessionid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Session Id: $sid"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Our support team is here to help",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Please contact our support team for assistance with your consultation",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            // SizedBox(height: 40),
            // ElevatedButton(
            //   onPressed: () {
            //     // Implement contact support functionality
            //   },
            //   child: Text("Contact Support"),
            // ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    "Redirecting to home in $_secondsRemaining seconds",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

