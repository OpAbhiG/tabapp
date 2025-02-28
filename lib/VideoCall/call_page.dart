import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../thankyoupage/thankyoupage.dart';
// import '../booking_confirmation/booking_confirmation.dart'; // Import the booking confirmation screen

class CallPage extends StatefulWidget {
  final String localUserId;
  final String id;
  const CallPage({
    super.key,
    required this.id,
    required this.localUserId,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool _showThankYouScreen = false;
  Timer? _autoNavigateTimer; // Timer for auto-navigation

  @override
  void initState() {
    super.initState();

    // Start a 10-minute timer to auto-navigate////////////
    _autoNavigateTimer = Timer(const Duration(minutes: 10), () {
      /////////////////////////////////////////////////////
      if (mounted) {
        _navigateToBookingConfirmation();
      }
    });

    // Listen for call end (when no users are in the room)
    // ZegoUIKit().getRoom().streamUserList.listen((userList) {
    //   if (userList.isEmpty) {
    //     _showThankYouOverlay();
    //   }
    // });

  }

  void _showThankYouOverlay() {
    setState(() {
      _showThankYouScreen = true;
    });

    // Automatically navigate to Booking Confirmation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToBookingConfirmation();
      }
    });
  }

  void _navigateToBookingConfirmation() {
    _autoNavigateTimer?.cancel(); // Cancel timer if navigation occurs early
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BookingConfirmationScreen()),
    );
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ZegoUIKitPrebuiltCall(
          appID: 584028794,
          appSign: "a11b4bd7368b5c96e3a87a3f7db21803b8f39a76f09604e7ce165d79d7e588b1",
          userID: widget.localUserId,
          userName: widget.localUserId,
          callID: widget.id,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..topMenuBar.isVisible = false
            ..bottomMenuBar.isVisible = true,
        ),

        // Show Thank You screen overlay in the middle
        if (_showThankYouScreen)
          Container(
            color: Colors.white.withOpacity(0.9),
            child: const Center(child: BookingConfirmationScreen()),
          ),
      ],
    );
  }
}
