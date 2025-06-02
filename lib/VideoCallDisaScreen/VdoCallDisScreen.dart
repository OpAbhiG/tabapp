import 'dart:convert';

import 'package:PatientTabletApp/topSection/topsection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../APIServices/base_api.dart';


class VideoCallDisconnectedScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? doctorDetails; // Made nullable
  final String sessionId;
  const VideoCallDisconnectedScreen({
    super.key,

    required this.token,
    required this.doctorDetails,
    required this.sessionId,


  });

  @override
  State<VideoCallDisconnectedScreen> createState() => _VideoCallDisconnectedScreenState();
}

class _VideoCallDisconnectedScreenState extends State<VideoCallDisconnectedScreen> {

  bool _isRetrying = false;
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }


  // Retry same doctor API call
  Future<void> _retrySameDoctor() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseapi/patient/retry_same_doctor_consultation'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'session_id': widget.sessionId,
          'latitude': _currentLatitude?.toString(),
          'longitude': _currentLongitude?.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Doctor re-notified successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // You can navigate to waiting screen or update UI as needed
        // For example, you might want to navigate back to a waiting screen
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => WaitingScreen(sessionId: widget.sessionId),
        //   ),
        // );

      } else {
        // Show error message
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to retry consultation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error retrying same doctor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRetrying = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 800;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            const TopSection(),
            const SizedBox(height: 10),

            // Header text with better responsive sizing
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * (isTablet ? 0.06 : 0.08),
                bottom: screenHeight * (isTablet ? 0.03 : 0.04),
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Text(
                    'Oops! Your video',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : screenWidth * 0.05,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'call got disconnected',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : screenWidth * 0.05,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : screenWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : screenWidth * 0.04),
                  child: isLandscape && isTablet
                      ? _buildLandscapeLayout(context, screenWidth, screenHeight, isTablet)
                      : _buildPortraitLayout(context, screenWidth, screenHeight, isTablet),
                ),
              ),
            ),

            SizedBox(height: screenHeight * (isTablet ? 0.09 : 0.11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, double screenWidth, double screenHeight, bool isTablet) {
    return Row(
      children: [
        // Doctor card
        Expanded(
          child: _buildDoctorCard(context, screenWidth, screenHeight, isTablet),
        ),
        SizedBox(width: isTablet ? 20 : screenWidth * 0.03),
        // Support card
        Expanded(
          child: _buildSupportCard(context, screenWidth, screenHeight, isTablet),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, double screenWidth, double screenHeight, bool isTablet) {
    return Row(
      children: [
        // Doctor card - wider in landscape
        Expanded(
          flex: 2,
          child: _buildDoctorCard(context, screenWidth, screenHeight, isTablet),
        ),
        const SizedBox(width: 20),
        // Support card - wider in landscape
        Expanded(
          flex: 2,
          child: _buildSupportCard(context, screenWidth, screenHeight, isTablet),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BuildContext context, double screenWidth, double screenHeight, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status text
            Text(
              'In progress call again',
              style: TextStyle(
                fontSize: isTablet ? 16 : screenWidth * 0.032,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 20 : screenHeight * 0.025),

            // Icon container with better tablet sizing
            Container(
              width: isTablet ? 120 : screenWidth * 0.25,
              height: isTablet ? 120 : screenWidth * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: isTablet ? 60 : screenWidth * 0.12,
                  height: isTablet ? 60 : screenWidth * 0.12,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: isTablet ? 32 : screenWidth * 0.07,
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 20 : screenHeight * 0.025),

            // Doctor info
            Text(
              widget.doctorDetails?['full_name'] ?? 'Dr. Unknown',
              style: TextStyle(
                fontSize: isTablet ? 18 : screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ), textAlign: TextAlign.center,

            ),
            SizedBox(height: isTablet ? 8 : screenHeight * 0.005),
            Text(
              '${widget.doctorDetails?['qualification'] ?? ''}, ${widget.doctorDetails?['speciality'] ?? ''}',
              style: TextStyle(
                fontSize: isTablet ? 14 : screenWidth * 0.03,
                color: Colors.black54,
              ), textAlign: TextAlign.center,

            ),

            const Spacer(),

            // Call Now button (Red)
            SizedBox(
              width: double.infinity,
              height: isTablet ? 60 : 50,
              child: ElevatedButton(
                onPressed: _isRetrying ? null : _retrySameDoctor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF243B6D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRetrying
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Connecting',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Call Now',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, double screenWidth, double screenHeight, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status text
            Text(
              'Need Help',
              style: TextStyle(
                fontSize: isTablet ? 16 : screenWidth * 0.032,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 20 : screenHeight * 0.025),

            // Icon container
            Container(
              width: isTablet ? 120 : screenWidth * 0.25,
              height: isTablet ? 120 : screenWidth * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: isTablet ? 60 : screenWidth * 0.12,
                  height: isTablet ? 60 : screenWidth * 0.12,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.headset_mic_sharp,
                    color: Colors.white,
                    size: isTablet ? 32 : screenWidth * 0.07,
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 20 : screenHeight * 0.025),

            // Support info
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: isTablet ? 18 : screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.black,

              ),textAlign: TextAlign.center,

            ),

            SizedBox(height: isTablet ? 24 : screenHeight * 0.03),

            const Spacer(),

            // Call Now button (Blue)
            SizedBox(
              width: double.infinity,
              height: isTablet ? 50 : screenHeight * 0.055,

              child: ElevatedButton(
                onPressed: () {
                  // Handle support call action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Call Now',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : screenWidth * 0.037,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
