// //audio is avialable not vdo
// // library;
// // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class Signaling {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   RTCPeerConnection? _peerConnection;
// //   MediaStream? _localStream;
// //   RTCVideoRenderer? _localRenderer;
// //   RTCVideoRenderer? _remoteRenderer;
// //
// //   void addConnectionStateListener(Function(RTCIceConnectionState) listener) {
// //     _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
// //       listener(state);
// //     };
// //   }
// //
// //   Future<void> initWebRTC(RTCVideoRenderer local, RTCVideoRenderer remote) async {
// //     _localRenderer = local;
// //     _remoteRenderer = remote;
// //
// //     try {
// //       _localStream = await navigator.mediaDevices.getUserMedia({
// //         'video': true,
// //         'audio': true,
// //       });
// //       _localRenderer?.srcObject = _localStream;
// //
// //
// //       //working from my side
// //       // final configuration = {
// //       // "iceServers": [
// //       // {"urls": "stun:stun.l.google.com:19302"},
// //       // {"urls": "stun:stun1.l.google.com:19302"},
// //       // // Add TURN servers here if needed
// //       // {
// //       // "urls": "turn:relay.metered.ca:80",
// //       // "username": "open",
// //       // "credential": "open"
// //       // },
// //       // ],
// //       // "sdpSemantics": "unified-plan",
// //       // "bundlePolicy": "balanced",
// //       // "iceTransportPolicy":"all",
// //       // };
// //
// //
// //       Map<String, dynamic> configuration = {
// //         "iceServers": [
// //           {"urls": "stun:stun.l.google.com:19302"},
// //           {"urls": "stun:stun1.l.google.com:19302"},
// //           // Add TURN servers here if needed for NAT traversal
// //         ],
// //         "sdpSemantics": "unified-plan",
// //         "bundlePolicy": "balanced",
// //       };
// //
// //       _peerConnection = await createPeerConnection(configuration, {});
// //
// //
// //       for (var track in _localStream!.getTracks()) {
// //         await _peerConnection!.addTrack(track, _localStream!);
// //       }
// //
// //       _peerConnection!.onTrack = (RTCTrackEvent event) {
// //         if (event.streams.isNotEmpty) {
// //           _remoteRenderer?.srcObject = event.streams[0];
// //         }
// //       };
// //
// //       _peerConnection!.onIceCandidate = (candidate) {
// //         // ICE Candidate handling will be done in createOffer/answerCall
// //       };
// //
// //     } catch (e) {
// //       throw Exception("Failed to initialize WebRTC: $e");
// //     }
// //   }
// //
// //   Future<void> createOffer(String callId) async {
// //     if (_peerConnection == null) {
// //       throw Exception("PeerConnection is null. Did you call initWebRTC() first?");
// //     }
// //
// //     _listenForLocalIceCandidates(callId);
// //
// //     try {
// //       RTCSessionDescription offer = await _peerConnection!.createOffer();
// //       await _peerConnection!.setLocalDescription(offer);
// //
// //       await _firestore.collection("calls").doc(callId).set({
// //         "offer": {
// //           "sdp": offer.sdp,
// //           "type": offer.type,
// //         },
// //         "status": "calling",
// //       });
// //
// //       listenForRemoteIceCandidates(callId);
// //     } catch (e) {
// //       throw Exception("Failed to create offer: $e");
// //     }
// //   }
// //
// //   Future<void> answerCall(String callId) async {
// //     if (_peerConnection == null) {
// //       throw Exception("PeerConnection is null. Did you call initWebRTC()?");
// //     }
// //
// //     _listenForLocalIceCandidates(callId);
// //
// //     try {
// //       DocumentSnapshot callDoc = await _firestore.collection("calls").doc(callId).get();
// //       if (!callDoc.exists || callDoc.data() == null) {
// //         throw Exception("No call document found for $callId");
// //       }
// //
// //       var data = callDoc.data() as Map<String, dynamic>;
// //       if (!data.containsKey("offer")) {
// //         throw Exception("No 'offer' found in Firestore for $callId");
// //       }
// //
// //       var offerData = data["offer"];
// //       RTCSessionDescription offer = RTCSessionDescription(
// //         offerData["sdp"],
// //         offerData["type"],
// //       );
// //       await _peerConnection!.setRemoteDescription(offer);
// //
// //       final answer = await _peerConnection!.createAnswer();
// //       await _peerConnection!.setLocalDescription(answer);
// //
// //       await _firestore.collection("calls").doc(callId).update({
// //         "answer": {
// //           "sdp": answer.sdp,
// //           "type": answer.type,
// //         },
// //         "status": "active",
// //       });
// //
// //       listenForRemoteIceCandidates(callId);
// //
// //     } catch (e) {
// //       throw Exception("Failed to answer call: $e");
// //     }
// //   }
// //
// //   void listenForRemoteAnswer(String callId) {
// //     _firestore.collection("calls").doc(callId).snapshots().listen((snapshot) {
// //       if (!snapshot.exists || snapshot.data() == null) return;
// //       var data = snapshot.data() as Map<String, dynamic>;
// //       if (data.containsKey("answer")) {
// //         var ans = data["answer"];
// //         final sdp = RTCSessionDescription(ans["sdp"], ans["type"]);
// //         _peerConnection?.setRemoteDescription(sdp);
// //       }
// //     });
// //   }
// //
// //   void _listenForLocalIceCandidates(String callId) {
// //     _peerConnection!.onIceCandidate = (candidate) async {
// //       if (candidate.candidate != null) {
// //         await _firestore
// //             .collection("calls")
// //             .doc(callId)
// //             .collection("candidates")
// //             .add({
// //           "candidate": candidate.candidate,
// //           "sdpMid": candidate.sdpMid,
// //           "sdpMLineIndex": candidate.sdpMLineIndex,
// //         });
// //       }
// //     };
// //   }
// //
// //   void listenForRemoteIceCandidates(String callId) {
// //     _firestore
// //         .collection("calls")
// //         .doc(callId)
// //         .collection("candidates")
// //         .snapshots()
// //         .listen((snapshot) {
// //       for (var docChange in snapshot.docChanges) {
// //         if (docChange.type == DocumentChangeType.added) {
// //           final data = docChange.doc.data();
// //           if (data == null) continue;
// //
// //           final candidate = RTCIceCandidate(
// //             data["candidate"],
// //             data["sdpMid"],
// //             data["sdpMLineIndex"],
// //           );
// //           _peerConnection?.addCandidate(candidate);
// //         }
// //       }
// //     });
// //   }
// //
// //   Future<void> dispose() async {
// //     _peerConnection?.close();
// //     _peerConnection = null;
// //
// //     if (_localStream != null) {
// //       for (var track in _localStream!.getTracks()) {
// //         track.stop();
// //       }
// //       await _localStream!.dispose();
// //     }
// //   }
// // }
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class CallerSignaling {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   RTCVideoRenderer? _localRenderer;
//   RTCVideoRenderer? _remoteRenderer;
//
//   final List<void Function()> _firestoreListeners = [];
//   final List<void Function(RTCIceConnectionState)> _connectionStateListeners = [];
//
//   /// Public method to add an ICE connection state listener
//   void addConnectionStateListener(void Function(RTCIceConnectionState) listener) {
//     _connectionStateListeners.add(listener);
//   }
//
//   Future<void> initWebRTC({
//     required RTCVideoRenderer localRenderer,
//     required RTCVideoRenderer remoteRenderer,
//   }) async {
//     debugPrint('[CALLER] initWebRTC() called.');
//     _localRenderer = localRenderer;
//     _remoteRenderer = remoteRenderer;
//
//     // 1) Request camera/mic permissions
//     await _requestPermissions();
//
//     // 2) Initialize local stream
//     await _initLocalStream();
//
//     // 3) Create PeerConnection
//     await _createPeerConnection();
//   }
//
//   Future<void> createOffer(String callId) async {
//     debugPrint('[CALLER] createOffer() => callId=$callId');
//     if (_peerConnection == null) {
//       throw Exception('[CALLER] PeerConnection is null. Call initWebRTC() first.');
//     }
//
//     _listenForLocalIceCandidates(callId);
//
//     final offer = await _peerConnection!.createOffer({
//       'offerToReceiveVideo': 1,
//       'offerToReceiveAudio': 1,
//     });
//     await _peerConnection!.setLocalDescription(offer);
//
//     final offerData = {
//       'sdp': offer.sdp,
//       'type': offer.type,
//     };
//
//     await _firestore.collection('calls').doc(callId).set({
//       'offer': offerData,
//       'status': 'calling',
//     });
//     debugPrint('[CALLER] Offer stored in Firestore at /calls/$callId.');
//
//     // Listen for remote answer & ICE
//     listenForRemoteAnswer(callId);
//     _listenForRemoteIceCandidates(callId);
//   }
//
//   // Make sure this method is public now
//   void listenForRemoteAnswer(String callId) {
//     final sub = _firestore
//         .collection('calls')
//         .doc(callId)
//         .snapshots()
//         .listen((snapshot) async {
//       if (!snapshot.exists || snapshot.data() == null) return;
//       final data = snapshot.data()!;
//       if (data.containsKey('answer')) {
//         final answerMap = data['answer'];
//         final answer = RTCSessionDescription(answerMap['sdp'], answerMap['type']);
//         debugPrint('[CALLER] Remote answer detected. Setting remote description...');
//         await _peerConnection?.setRemoteDescription(answer);
//       }
//     });
//
//     _firestoreListeners.add(sub.cancel);
//   }
//
//   void _listenForLocalIceCandidates(String callId) {
//     _peerConnection?.onIceCandidate = (candidate) async {
//       if (candidate.candidate != null) {
//         debugPrint('[CALLER] Local ICE candidate: ${candidate.candidate}');
//         await _firestore
//             .collection('calls')
//             .doc(callId)
//             .collection('callerCandidates')
//             .add({
//           'candidate': candidate.candidate,
//           'sdpMid': candidate.sdpMid,
//           'sdpMLineIndex': candidate.sdpMLineIndex,
//         });
//       }
//     };
//   }
//
//   void _listenForRemoteIceCandidates(String callId) {
//     final sub = _firestore
//         .collection('calls')
//         .doc(callId)
//         .collection('calleeCandidates')
//         .snapshots()
//         .listen((snapshot) {
//       for (var docChange in snapshot.docChanges) {
//         if (docChange.type == DocumentChangeType.added) {
//           final data = docChange.doc.data();
//           if (data == null) continue;
//           final candidate = RTCIceCandidate(
//             data['candidate'],
//             data['sdpMid'],
//             data['sdpMLineIndex'],
//           );
//           debugPrint('[CALLER] Adding remote ICE candidate: ${candidate.candidate}');
//           _peerConnection?.addCandidate(candidate);
//         }
//       }
//     });
//     _firestoreListeners.add(sub.cancel);
//   }
//
//   Future<void> dispose() async {
//     debugPrint('[CALLER] dispose() called.');
//     for (var cancel in _firestoreListeners) {
//       cancel();
//     }
//     _firestoreListeners.clear();
//
//     await _peerConnection?.close();
//     _peerConnection = null;
//
//     if (_localStream != null) {
//       for (var track in _localStream!.getTracks()) {
//         track.stop();
//       }
//       await _localStream?.dispose();
//     }
//     _localStream = null;
//
//     _localRenderer?.srcObject = null;
//     _remoteRenderer?.srcObject = null;
//
//     debugPrint('[CALLER] Cleanup complete.');
//   }
//
//   // ------------------ Private Helpers ------------------
//   Future<void> _requestPermissions() async {
//     // Only needed on mobile.
//     // For web, or if you handle permissions differently, remove this step
//     debugPrint('[CALLER] Requesting camera & mic permissions...');
//     final statuses = await [Permission.camera, Permission.microphone].request();
//     if (statuses[Permission.camera] != PermissionStatus.granted ||
//         statuses[Permission.microphone] != PermissionStatus.granted) {
//       throw Exception('[CALLER] Camera or microphone permission not granted.');
//     }
//     debugPrint('[CALLER] Permissions granted.');
//   }
//
//   Future<void> _initLocalStream() async {
//     debugPrint('[CALLER] Initializing local media stream...');
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': true,
//     });
//     _localRenderer?.srcObject = _localStream;
//     debugPrint('[CALLER] Local stream initialized.');
//   }
//
//   Future<void> _createPeerConnection() async {
//     debugPrint('[CALLER] Creating RTCPeerConnection...');
//     final configuration = {
//       'iceServers': [
//         {
//           'urls': 'stun:stun.l.google.com:19302',
//         },
//       ],
//       'sdpSemantics': 'unified-plan',
//     };
//
//     _peerConnection = await createPeerConnection(configuration);
//
//     // Add local tracks
//     for (final track in _localStream!.getTracks()) {
//       await _peerConnection!.addTrack(track, _localStream!);
//       debugPrint('[CALLER] Added local track => kind=${track.kind}');
//     }
//
//     // Notify any registered ICE connection state listeners
//     _peerConnection!.onIceConnectionState = (state) {
//       debugPrint('[CALLER] ICE connection state changed to: $state');
//       for (var cb in _connectionStateListeners) {
//         cb(state);
//       }
//     };
//
//     // Remote track event
//     _peerConnection!.onTrack = (RTCTrackEvent event) {
//       debugPrint('[CALLER] onTrack => kind=${event.track.kind}');
//       if (event.track.kind == 'video' && event.streams.isNotEmpty) {
//         _remoteRenderer?.srcObject = event.streams[0];
//         debugPrint('[CALLER] Remote video stream set on _remoteRenderer!');
//       }
//     };
//
//     debugPrint('[CALLER] PeerConnection created.');
//   }
// }