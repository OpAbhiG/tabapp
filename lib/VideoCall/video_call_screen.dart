//
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../SerialCommunication/USB_oxymitter_sensor.dart';
// // import 'signaling.dart';
// //
// // class VideoCallScreen extends StatefulWidget {
// //   final String appointmentId;
// //   // final String userId;
// //
// //   const VideoCallScreen({
// //     super.key,
// //     required this.appointmentId,
// //     // required this.userId,
// //   });
// //
// //   @override
// //   State<VideoCallScreen> createState() => _VideoCallScreenState();
// // }
// // class _VideoCallScreenState extends State<VideoCallScreen> {
// //   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
// //   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
// //   final Signaling _signaling = Signaling();
// //
// //   String errorMessage = "";
// //   bool isCallActive = false;
// //   bool isMuted = false;
// //   bool _isDisposing = false;
// //   Duration _callDuration = Duration.zero;
// //   Timer? _callTimer;
// //   RTCIceConnectionState _connectionState = RTCIceConnectionState.RTCIceConnectionStateNew;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeVideoCall();
// //   }
// //
// //   // Future<void> _initializeVideoCall() async {
// //   //   try {
// //   //     await _initializeRenderers();
// //   //     await _initializeWebRTC();
// //   //     _setupConnectionListeners();
// //   //     // _autoStartCall();
// //   //   } catch (e) {
// //   //     _handleError("Initialization failed: ${e.toString()}");
// //   //   }
// //   // }
// //
// //   Future<void> _initializeVideoCall() async {
// //     try {
// //       await _localRenderer.initialize();
// //       await _remoteRenderer.initialize();
// //       await _signaling.initWebRTC(_localRenderer, _remoteRenderer);
// //       _setupConnectionListeners();
// //
// //       // Automatically start the call once initialized
// //       _startCall();
// //     } catch (e) {
// //       _handleError("Initialization failed: ${e.toString()}");
// //     }
// //   }
// //
// //   Future<void> _initializeRenderers() async {
// //     try {
// //       await _localRenderer.initialize();
// //       await _remoteRenderer.initialize();
// //     } catch (e) {
// //       _handleError("Renderer initialization failed: ${e.toString()}");
// //     }
// //   }
// //
// //   Future<void> _initializeWebRTC() async {
// //     if (_isDisposing) return;
// //     try {
// //       await _signaling.initWebRTC(_localRenderer, _remoteRenderer);
// //     } catch (e) {
// //       _handleError("WebRTC setup failed: ${e.toString()}");
// //     }
// //   }
// //
// //   void _setupConnectionListeners() {
// //     _signaling.addConnectionStateListener((state) {
// //       if (!mounted) return;
// //       setState(() => _connectionState = state);
// //
// //       if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
// //         _endCall();
// //       }
// //     });
// //   }
// //
// //   // void _autoStartCall() {
// //   //   if (widget.userId.startsWith('doctor')) {
// //   //     _joinCall();
// //   //   } else {
// //   //     _startCall();
// //   //   }
// //   // }
// //
// //   Future<void> _startCall() async {
// //     try {
// //       await _signaling.createOffer(widget.appointmentId);
// //       _signaling.listenForRemoteAnswer(widget.appointmentId);
// //       _startTimer();
// //       if (!mounted) return;
// //       setState(() => isCallActive = true);
// //     } catch (e) {
// //       _handleError("Failed to start call: ${e.toString()}");
// //     }
// //   }
// //
// //   // Future<void> _joinCall() async {
// //   //   try {
// //   //     await _signaling.answerCall(widget.appointmentId);
// //   //     _startTimer();
// //   //     if (!mounted) return;
// //   //     setState(() => isCallActive = true);
// //   //   } catch (e) {
// //   //     _handleError("Failed to join call: ${e.toString()}");
// //   //   }
// //   // }
// //
// //   void _startTimer() {
// //     _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (!mounted || _isDisposing) timer.cancel();
// //       setState(() => _callDuration += const Duration(seconds: 1));
// //     });
// //   }
// //
// //   Future<void> _endCall() async {
// //     if (_isDisposing) return;
// //     _isDisposing = true;
// //
// //     try {
// //       // 1. Cleanup WebRTC resources
// //       await _signaling.dispose();
// //
// //       // 2. Update Firestore call status
// //       await FirebaseFirestore.instance
// //           .collection('calls')
// //           .doc(widget.appointmentId)
// //           .update({'status': 'ended'});
// //
// //       // 3. Cancel timer
// //       _callTimer?.cancel();
// //
// //       // 4. Navigate back
// //       if (mounted) {
// //         Navigator.pop(context);
// //         Navigator.pop(context);
// //         Navigator.pop(context);
// //         Navigator.pop(context);
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _handleError("Error ending call: ${e.toString()}");
// //       }
// //     }
// //   }
// //
// //   void _toggleMute() {
// //     final audioTracks = _localRenderer.srcObject?.getAudioTracks();
// //     if (audioTracks?.isNotEmpty ?? false) {
// //       setState(() {
// //         isMuted = !isMuted;
// //         audioTracks!.first.enabled = !isMuted;
// //       });
// //     }
// //   }
// //
// //   void _handleError(String message) {
// //     if (!mounted || _isDisposing) return;
// //     setState(() => errorMessage = message);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _isDisposing = true;
// //     _callTimer?.cancel();
// //     _signaling.dispose();
// //     _localRenderer.dispose();
// //     _remoteRenderer.dispose();
// //
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Stack(
// //         children: [
// //           // Remote Video Feed
// //           Positioned.fill(
// //             child: RTCVideoView(_remoteRenderer),
// //           ),
// //           const SerialPort(),
// //
// //           // Local Video Preview
// //           Positioned(
// //             top: 30,
// //             right: 10,
// //             child: Container(
// //               width: 120,
// //               height: 160,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(10),
// //                 border: Border.all(color: Colors.white, width: 2),
// //               ),
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(8),
// //                 child: RTCVideoView(_localRenderer, mirror: true),
// //               ),
// //             ),
// //           ),
// //
// //           // Call Status Header
// //           Positioned(
// //             top: 30,
// //             left: 20,
// //             child: Row(
// //               children: [
// //                 _ConnectionIndicator(state: _connectionState),
// //                 const SizedBox(width: 10),
// //                 Text(
// //                   '${_callDuration.inMinutes}:${(_callDuration.inSeconds % 60).toString().padLeft(2, '0')}',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //
// //           // Control Buttons
// //           Positioned(
// //             bottom: 40,
// //             left: 0,
// //             right: 0,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 // IconButton(
// //                 //   icon: Icon(
// //                 //     isMuted ? Icons.mic_off : Icons.mic,
// //                 //     color: Colors.white,
// //                 //     size: 30,
// //                 //   ),
// //                 //   onPressed: isCallActive ? _toggleMute : null,
// //                 // ),
// //                 Container(
// //                   decoration: const BoxDecoration(
// //                     shape: BoxShape.circle, // Ensures the button is circular
// //                     color: Colors.blue, // You can change the background color
// //                   ),
// //                   child: IconButton(
// //                     icon: Icon(
// //                       isMuted ? Icons.mic_off : Icons.mic,
// //                       color: Colors.white,
// //                       size: 30,
// //                     ),
// //                     onPressed: isCallActive ? _toggleMute : null,
// //                   ),
// //                 ),
// //
// //                 // FloatingActionButton(
// //                 //   onPressed: isCallActive ? null : _startCall,
// //                 //   backgroundColor: Colors.green,
// //                 //   child: const Icon(Icons.call, color: Colors.white),
// //                 // ),
// //                 // FloatingActionButton(
// //                 //   onPressed: _endCall,
// //                 //   backgroundColor: Colors.red,
// //                 //   shape: const CircleBorder(),
// //                 //   child: const Icon(Icons.call_end, color: Colors.white), // Ensures a circular shape
// //                 // ),
// //                 Container(
// //                   decoration: const BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color: Colors.red, // Red color for reject call button
// //                   ),
// //                   child: IconButton(
// //                     icon: const Icon(
// //                       Icons.call_end,
// //                       color: Colors.white,
// //                       size: 30,
// //                     ),
// //                     onPressed: isCallActive ? _endCall : null,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // Error Display
// //           if (errorMessage.isNotEmpty)
// //             Positioned(
// //
// //               top: 70,
// //               left: 20,
// //               right: 20,
// //               child: Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.redAccent.withOpacity(0.9),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Text(
// //                   errorMessage,
// //                   style: const TextStyle(color: Colors.white),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ),
// //
// //         ],
// //       ),
// //     );
// //   }
// //
// //
// // }
// // class _ConnectionIndicator extends StatelessWidget {
// //   final RTCIceConnectionState state;
// //
// //   const _ConnectionIndicator({required this.state});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: _indicatorColor.withOpacity(0.8),
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(_indicatorIcon, size: 16, color: Colors.white),
// //           const SizedBox(width: 6),
// //           Text(
// //             _statusText,
// //             style: const TextStyle(color: Colors.white, fontSize: 12),
// //           ),
// //
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Color get _indicatorColor {
// //     switch (state) {
// //       case RTCIceConnectionState.RTCIceConnectionStateConnected:
// //         return Colors.green;
// //       case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
// //         return Colors.orange;
// //       case RTCIceConnectionState.RTCIceConnectionStateFailed:
// //         return Colors.red;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// //
// //   IconData get _indicatorIcon {
// //     switch (state) {
// //       case RTCIceConnectionState.RTCIceConnectionStateConnected:
// //         return Icons.check_circle;
// //       case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
// //         return Icons.error_outline;
// //       case RTCIceConnectionState.RTCIceConnectionStateFailed:
// //         return Icons.cancel;
// //       default:
// //         return Icons.cloud;
// //     }
// //   }
// //
// //   String get _statusText {
// //     switch (state) {
// //       case RTCIceConnectionState.RTCIceConnectionStateConnected:
// //         return 'Connected';
// //       case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
// //         return 'Poor Connection';
// //       case RTCIceConnectionState.RTCIceConnectionStateFailed:
// //         return 'Connection Failed';
// //       default:
// //         return 'Connecting...';
// //     }
// //   }
// // }
//
//
//
// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:tablet_degim/VideoCall/signaling.dart';
//
// class VideoCallScreen extends StatefulWidget {
//   final String appointmentId;  // Firestore doc ID representing the call
//
//   const VideoCallScreen({
//     super.key,
//     required this.appointmentId,
//   });
//
//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   // Our local/remote video renderers
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//
//   // Use your new CallerSignaling class
//   final CallerSignaling _signaling = CallerSignaling();
//
//   // UI / State management
//   String errorMessage = "";
//   bool isCallActive = false;
//   bool isMuted = false;
//   bool _isDisposing = false;
//
//   // Track call duration with a Timer
//   Duration _callDuration = Duration.zero;
//   Timer? _callTimer;
//
//   // Track ICE connection state for UI display
//   RTCIceConnectionState _connectionState =
//       RTCIceConnectionState.RTCIceConnectionStateNew;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoCall();
//   }
//
//
//   Future<void> _initializeVideoCall() async {
//     debugPrint("[CALLER] _initializeVideoCall => appointmentId=${widget.appointmentId}");
//     try {
//       // 1) Init local/remote video renderers
//       await _localRenderer.initialize();
//       await _remoteRenderer.initialize();
//
//       // 2) Initialize WebRTC in the signaling class
//       //    This requests camera/mic, sets up the peer connection, etc.
//       await _signaling.initWebRTC(
//         localRenderer: _localRenderer,
//         remoteRenderer: _remoteRenderer,
//       );
//
//       // 3) Setup ICE connection listeners for debug
//       _setupConnectionListeners();
//
//       // 4) Automatically start the call
//       _startCall();
//     } catch (e) {
//       _handleError("Initialization failed: $e");
//     }
//   }
//
//   /// Listen for ICE connection state changes to handle disconnected states or debugging
//   void _setupConnectionListeners() {
//     _signaling.addConnectionStateListener((state) {
//       if (!mounted) return;
//       debugPrint("[CALLER] ICE Connection State => $state");
//       setState(() => _connectionState = state);
//
//       // If the connection is lost, end the call
//       if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
//           state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
//         _endCall();
//       }
//     });
//   }
//
//   /// Create an Offer and wait for the Callee to answer
//   Future<void> _startCall() async {
//     debugPrint("[CALLER] _startCall => callId=${widget.appointmentId}");
//     try {
//       // 1) Create an Offer in Firestore
//       await _signaling.createOffer(widget.appointmentId);
//
//       _signaling.listenForRemoteAnswer(widget.appointmentId);
//
//       // 3) Start call timer
//       _startTimer();
//
//       setState(() => isCallActive = true);
//     } catch (e) {
//       _handleError("Failed to start call: $e");
//     }
//   }
//
//   /// Start a periodic timer to measure call duration
//   void _startTimer() {
//     _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted || _isDisposing) {
//         timer.cancel();
//         return;
//       }
//       setState(() {
//         _callDuration += const Duration(seconds: 1);
//       });
//     });
//   }
//
//   Future<void> _endCall() async {
//     if (_isDisposing) return;
//     _isDisposing = true;
//
//     debugPrint("[CALLER] _endCall => appointmentId=${widget.appointmentId}");
//     try {
//       // 1) Cleanup WebRTC resources
//       await _signaling.dispose();
//
//       // 2) Update Firestore doc to 'ended' or remove it.
//       await FirebaseFirestore.instance
//           .collection('calls')
//           .doc(widget.appointmentId)
//           .update({'status': 'ended'});
//
//       // 3) Cancel the timer
//       _callTimer?.cancel();
//
//       // 4) Pop the screen(s)
//       if (mounted) {
//         Navigator.pop(context);
//         Navigator.pop(context);
//         Navigator.pop(context);
//         Navigator.pop(context);
//
//       }
//     } catch (e) {
//       debugPrint("[CALLER] Error ending call: $e");
//       if (mounted) {
//         _handleError("Error ending call: $e");
//       }
//     }
//   }
//
//   /// Mute/unmute local audio
//   void _toggleMute() {
//     final audioTracks = _localRenderer.srcObject?.getAudioTracks();
//     if (audioTracks?.isNotEmpty ?? false) {
//       setState(() {
//         isMuted = !isMuted;
//         audioTracks!.first.enabled = !isMuted;
//       });
//       debugPrint("[CALLER] Mute toggled => isMuted=$isMuted");
//     }
//   }
//
//   /// Show an error message in the UI
//   void _handleError(String message) {
//     if (!mounted || _isDisposing) return;
//     debugPrint("[CALLER] ERROR: $message");
//     setState(() => errorMessage = message);
//   }
//
//   @override
//   void dispose() {
//     debugPrint("[CALLER] VideoCallScreen dispose...");
//     _isDisposing = true;
//
//     // Stop call timer
//     _callTimer?.cancel();
//     _callTimer = null;
//
//     // Dispose signaling & streams
//     _signaling.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // 1) Remote Video Fullscreen
//           Positioned.fill(
//             child: RTCVideoView(_remoteRenderer),
//           ),
//
//           // 2) Local Video Preview (top-right)
//           Positioned(
//             top: 30,
//             right: 10,
//             child: Container(
//               width: 120,
//               height: 160,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: RTCVideoView(_localRenderer, mirror: true),
//               ),
//             ),
//           ),
//
//           // 3) Connection Indicator + Timer at top-left
//           Positioned(
//             top: 30,
//             left: 20,
//             child: Row(
//               children: [
//                 _ConnectionIndicator(state: _connectionState),
//                 const SizedBox(width: 10),
//                 Text(
//                   _formatCallDuration(_callDuration),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // 4) Bottom controls (Mute, End call)
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Mute Button
//                 Container(
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.blue,
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       isMuted ? Icons.mic_off : Icons.mic,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: isCallActive ? _toggleMute : null,
//                   ),
//                 ),
//                 // End Call Button
//                 Container(
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.red,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.call_end,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: isCallActive ? _endCall : null,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // 5) Error Display
//           if (errorMessage.isNotEmpty)
//             Positioned(
//               top: 70,
//               left: 20,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.redAccent.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   errorMessage,
//                   style: const TextStyle(color: Colors.white),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   /// Formats the call duration as "MM:SS"
//   String _formatCallDuration(Duration duration) {
//     final minutes = duration.inMinutes;
//     final seconds = duration.inSeconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }
// }
//
// /// A small widget to show the ICE connection state visually
// class _ConnectionIndicator extends StatelessWidget {
//   final RTCIceConnectionState state;
//
//   const _ConnectionIndicator({required this.state});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: _indicatorColor.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Icon(_indicatorIcon, size: 16, color: Colors.white),
//           const SizedBox(width: 6),
//           Text(
//             _statusText,
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color get _indicatorColor {
//     switch (state) {
//       case RTCIceConnectionState.RTCIceConnectionStateConnected:
//         return Colors.green;
//       case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
//         return Colors.orange;
//       case RTCIceConnectionState.RTCIceConnectionStateFailed:
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData get _indicatorIcon {
//     switch (state) {
//       case RTCIceConnectionState.RTCIceConnectionStateConnected:
//         return Icons.check_circle;
//       case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
//         return Icons.error_outline;
//       case RTCIceConnectionState.RTCIceConnectionStateFailed:
//         return Icons.cancel;
//       default:
//         return Icons.cloud;
//     }
//   }
//
//   String get _statusText {
//     switch (state) {
//       case RTCIceConnectionState.RTCIceConnectionStateConnected:
//         return 'Connected';
//       case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
//         return 'Poor Connection';
//       case RTCIceConnectionState.RTCIceConnectionStateFailed:
//         return 'Connection Failed';
//       default:
//         return 'Connecting...';
//     }
//   }
// }
//
//
//
//
