import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../SerialCommunication/USB_oxymitter_sensor.dart';
import '../thankyoupage/thankyoupage.dart';
import 'common.dart';

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
  double bloodOxygen = 0;
  double heartRate = 0;
  double bodyTemp = 0.0;
  late StreamSubscription sensorSubscription;
  Timer? apiTimer;

  // Lists to store readings for averaging
  List<double> bloodOxygenList = [];
  List<double> heartRateList = [];
  List<double> bodyTempList = [];

  @override
  void initState() {
    super.initState();
    SerialPortService().start();
    _startListeningToSensor();
    _startAPITimer();
  }

  void _startListeningToSensor() {
    sensorSubscription = SerialPortService().sensorDataStream.listen((data) {
      if (mounted) {
        setState(() {
          bloodOxygen = data['bloodOxygen'] ?? 0;
          heartRate = data['heartRate'] ?? 0;
          bodyTemp = data['bodyTemp'] ?? 0;
        });

        // Add values to lists for averaging
        if (bloodOxygen > 0) bloodOxygenList.add(bloodOxygen);
        if (heartRate > 0) heartRateList.add(heartRate);
        if (bodyTemp > 0) bodyTempList.add(bodyTemp);
      }
    });
  }

  void _startAPITimer() {
    apiTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendAveragedSensorData();
    });
  }

  Future<void> _sendAveragedSensorData() async {
    if (bloodOxygenList.isEmpty || heartRateList.isEmpty || bodyTempList.isEmpty) {
      print("⏳ Skipping API call: No valid sensor data collected.");
      return;
    }

    // Compute averages
    double avgOxygen = bloodOxygenList.reduce((a, b) => a + b) / bloodOxygenList.length;
    double avgHeart = heartRateList.reduce((a, b) => a + b) / heartRateList.length;
    double avgTemp = bodyTempList.reduce((a, b) => a + b) / bodyTempList.length;

    // Ignore sending if all values are zero
    if (avgOxygen == 0 && avgHeart == 0 && avgTemp == 0) {
      print("🚫 Skipping API call: All values are zero.");
      return;
    }

    // Prepare API request
    Map<String, dynamic> payload = {
      "patient_id": widget.localUserId,
      "blood_oxygen": avgOxygen,
      "heart_rate": avgHeart,
      "body_temp": avgTemp
    };

    print("📤 Sending API Data: $payload");

    try {
      final response = await http.post(
        Uri.parse("https://your-api.com/patient/patient-oxy-vital"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("✅ API Success! Response: ${response.body}");
      } else {
        print("❌ API Failed! Status: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("⚠️ API Error: $e");
    }

    // Clear lists after sending to collect new data
    bloodOxygenList.clear();
    heartRateList.clear();
    bodyTempList.clear();
  }

  void endCallAndGoToThankYouPage() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingConfirmationScreen()),
      );
    }
  }

  @override
  void dispose() {
    sensorSubscription.cancel();
    apiTimer?.cancel();
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
            ..topMenuBar.isVisible = true
            ..bottomMenuBar.isVisible = false
            ..avatarBuilder = customAvatarBuilder,
        ),

        // Custom Floating Hang-Up Button
        Positioned(
          bottom:15,
          left: MediaQuery.of(context).size.width / 2 - 28, // Center the button
          child: Container(
            width: 60, // Circle size
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red, // Circular background color
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.call_end, color: Colors.white, size: 32), // Call end icon
              onPressed: () {
                endCallAndGoToThankYouPage(); // Custom navigation
              },
            ),
          ),
        ),



        Positioned(
          bottom: 80,
          left: 10,
          right: 10,
          child: SensorDataWidget(
            bloodOxygen: bloodOxygen,
            heartRate: heartRate,
            bodyTemp: bodyTemp,
          ),
        ),
      ],
    );
  }
}

class SensorDataWidget extends StatelessWidget {
  final double bloodOxygen;
  final double heartRate;
  final double bodyTemp;

  const SensorDataWidget({
    super.key,
    required this.bloodOxygen,
    required this.heartRate,
    required this.bodyTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4), // 70% opacity black
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SensorCard(title: "Oxygen", value: "$bloodOxygen%", icon: Icons.bubble_chart, iconColor: Colors.blue),
          SensorCard(title: "Heart Rate", value: "$heartRate BPM", icon: Icons.favorite, iconColor: Colors.red),
          SensorCard(title: "Temp", value: "$bodyTemp °C", icon: Icons.thermostat, iconColor: Colors.orange),
        ],
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor; // Add iconColor parameter


  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10,decoration: TextDecoration.none)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
      ],
    );
  }
}
