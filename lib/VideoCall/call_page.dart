import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../SerialCommunication/USB_oxymitter_sensor.dart';
import '../thankyoupage/thankyoupage.dart';
import 'common.dart';

class CallPage extends StatefulWidget {
  final String localUserId;
  final String id;
  final String sessionid;

  const CallPage({
    super.key,
    required this.id,
    required this.localUserId,
    required this.sessionid,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  double bloodOxygen = 0;
  double heartRate = 0;
  double bodyTemp = 0.0;
  late StreamSubscription sensorSubscription;

  @override
  void initState() {
    super.initState();
    SerialPortService().start(); // ✅ Start SerialPort service
    _startListeningToSensor();
  }

  void _startListeningToSensor() {
    sensorSubscription = SerialPortService().sensorDataStream.listen((data) {
      if (mounted) {
        setState(() {
          bloodOxygen = data['bloodOxygen'] ?? 0;
          heartRate = data['heartRate'] ?? 0;
          bodyTemp = data['bodyTemp'] ?? 0;
        });
      }
    });
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
    sensorSubscription.cancel(); // ✅ Proper cleanup
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
            ..bottomMenuBar.isVisible = true
            ..avatarBuilder = customAvatarBuilder,


        ),

        Positioned(
          bottom: 80, // Adjust to position above the floating button
          left: 10, // Center alignment
          right:10,
          child: SensorDataWidget(
            bloodOxygen: bloodOxygen,
            heartRate: heartRate,
            bodyTemp: bodyTemp,
          ),
        ),


        // // ✅ Floating Hang-Up Button
        Positioned(
          bottom: 20,
          left: MediaQuery.of(context).size.width / 2 - 30,
          right: MediaQuery.of(context).size.width / 2 - 30,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: endCallAndGoToThankYouPage,
            child: const Icon(Icons.download, color: Colors.black),
          ),
        ),

      ],
    );
  }
}


/// ✅ Sensor Data Display Widget (Aligned at the Bottom Center)
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
    return Positioned(
      bottom: 80, // Adjust the position above the call button
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // ✅ Adjust width
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SensorCard(title: "Oxygen", value: "$bloodOxygen%", icon: Icons.bubble_chart,),
              SensorCard(title: "Heart Rate", value: "$heartRate BPM", icon: Icons.favorite),
              SensorCard(title: "Temp", value: "$bodyTemp °C", icon: Icons.thermostat),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Individual Sensor Card Widget
class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //   color: Colors.black.withOpacity(0.7), // Dark background
      //   borderRadius: BorderRadius.circular(10),
      // ),
      // child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.white, size: 20), // Sensor Icon
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10, decoration: TextDecoration.none,),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,decoration: TextDecoration.none,),
          ),
        ],
      ),
      // ),
    );
  }

}


