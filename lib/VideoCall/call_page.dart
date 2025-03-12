import 'dart:async';
import 'package:PatientTabletApp/APIServices/base_api.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../SerialCommunication/USB_oxymitter_sensor.dart';
// import '../thankyoupage/thankyoupage.dart';
import 'common.dart';
import 'package:http/http.dart' as http;


import 'dart:convert';

class TabPrescriptionScreen extends StatefulWidget {
  final String sessionId;
  final String token;

  const TabPrescriptionScreen({
    super.key,
    required this.sessionId,
    required this.token,
  });

  @override
  _TabPrescriptionScreenState createState() => _TabPrescriptionScreenState();
}

class _TabPrescriptionScreenState extends State<TabPrescriptionScreen> {
  bool isLoading = true;
  List<dynamic> prescriptions = [];
  String doctorName = '';
  String licenseNumber = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPrescriptionData();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> fetchPrescriptionData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Build the URL with query parameters
      final Uri uri = Uri.parse('$baseapi/tab/get_drug_list_by_session')
          .replace(queryParameters: {'session_id': widget.sessionId});

      // Make the GET request
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      // Check response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          doctorName = data['doctor_name'] ?? 'Unknown Doctor';
          licenseNumber = data['license'] ?? '';
          prescriptions = data['prescriptions'] ?? [];
          isLoading = false;
        });

        print('Prescription data fetched successfully: ${response.body}');
      } else {
        setState(() {
          errorMessage = 'Failed to fetch prescriptions: ${response.statusCode}';
          isLoading = false;
        });
        print('Failed to fetch prescriptions: ${response.statusCode}');
        print('Response: ${response.body}');
        _showSnackBar('Failed to fetch prescriptions');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception when fetching prescriptions: $e';
        isLoading = false;
      });
      print('Exception when fetching prescriptions: $e');
      _showSnackBar('Error loading prescriptions');
    }
  }

  String getFrequencyPattern(dynamic frequencyValue) {
    if (frequencyValue == null) return 'Unknown Frequency';

    final Map<String, String> frequencyMapping = {
      '1': '0-0-1',
      '2': '0-1-0',
      '3': '0-1-1',
      '4': '1-0-0',
      '5': '1-0-1',
      '6': '1-1-0',
      '7': '1-1-1',
    };

    String frequencyString = frequencyValue.toString();
    return frequencyMapping[frequencyString] ?? 'Unknown Frequency';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243B6D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPrescriptionData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchPrescriptionData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : prescriptions.isEmpty
          ? const Center(child: Text('No prescriptions found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor: $doctorName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF243B6D),
                      ),
                    ),
                    if (licenseNumber.isNotEmpty)
                      Text(
                        'License: $licenseNumber',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Prescribed Medications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF243B6D),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${prescription['drug_name'] ?? 'Unknown Medication'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF243B6D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dosage: ${prescription['dosage'] ?? ''} ${prescription['unit'] ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Frequency: ${getFrequencyPattern(prescription['frequency'])}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Duration: ${prescription['duration'] ?? ''} days',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (prescription['instruction'] != null)
                          Text(
                            'Instructions: ${prescription['instruction']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (prescription['notes'] != null)
                          Text(
                            'Notes: ${prescription['notes']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${prescription['created_at'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// API Service Class
class SensorApiService {
  final String baseUrl;
  final String token;
  final String sessionId;
  Timer? _apiTimer;

  // Last sent values to prevent duplicate API calls with same data
  double _lastSentOxygen = -1;
  double _lastSentHeartRate = -1;
  double _lastSentTemp = -1;

  SensorApiService({
    required this.baseUrl,
    required this.token,
    required this.sessionId,
  });

  // Start sending data at regular intervals
  void startSendingData(
      double Function() getOxygen,
      double Function() getHeartRate,
      double Function() getTemp,
      ) {
    // Cancel any existing timer
    _apiTimer?.cancel();

    // Send data every 5 seconds (adjust interval as needed)
    _apiTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final oxygen = getOxygen();
      final heartRate = getHeartRate();
      final temp = getTemp();

      // Only send data when finger is inserted (values are not 0)
      // And only when values have changed from last sent values
      if ((oxygen > 0 || heartRate > 0 || temp > 0) &&
          (oxygen != _lastSentOxygen || heartRate != _lastSentHeartRate || temp != _lastSentTemp)) {
        sendSensorData(oxygen, heartRate, temp);

        // Update last sent values
        _lastSentOxygen = oxygen;
        _lastSentHeartRate = heartRate;
        _lastSentTemp = temp;
      }
    });
  }

  // Stop sending data
  void stopSendingData() {
    _apiTimer?.cancel();
    _apiTimer = null;
  }

  // Send data to API using form-data format as shown in Postman
  Future<void> sendSensorData(double oxygen, double heartRate, double temp) async {
    try {
      // Create form data
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/patient/patient-oxy-vital')
      );

      // Add form fields matching Postman screenshot
      request.fields['session_id'] = sessionId;
      request.fields['temperature'] = temp.toString();
      request.fields['heart_rate'] = heartRate.toString();
      request.fields['oxygen_saturation'] = oxygen.toString();

      // Set headers with bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Vitals sent successfully: ${response.body}');
      } else {
        print('Failed to send vitals: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Exception when sending vitals data: $e');
    }
  }

  // Manual send for immediate data transmission
  Future<bool> sendDataNow(double oxygen, double heartRate, double temp) async {
    try {
      await sendSensorData(oxygen, heartRate, temp);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CallPage extends StatefulWidget {
  final String localUserId;
  final String id;
  final String sessionid;
  final String token;

  const CallPage({
    super.key,
    required this.id,
    required this.localUserId,
    required this.sessionid,
    required this.token,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  double bloodOxygen = 0;
  double heartRate = 0;
  double bodyTemp = 0.0;
  late StreamSubscription sensorSubscription;

  // Add SensorApiService instance
  late SensorApiService _apiService;

  @override
  void initState() {
    super.initState();

    // Initialize the API service with token and session ID
    _apiService = SensorApiService(
      baseUrl: baseapi, // Replace with your actual API URL
      token: widget.token,
      sessionId: widget.sessionid,
    );

    SerialPortService().start(); // ✅ Start SerialPort service
    _startListeningToSensor();

    // Start sending data to API
    _apiService.startSendingData(
          () => bloodOxygen,
          () => heartRate,
          () => bodyTemp,
    );
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
    // Send final data snapshot before ending call
    if (bloodOxygen > 0 || heartRate > 0 || bodyTemp > 0) {
      _apiService.sendDataNow(bloodOxygen, heartRate, bodyTemp);
    }

    // Stop API service
    _apiService.stopSendingData();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TabPrescriptionScreen(sessionId: widget.sessionid, token: widget.token,)),
      );
    }
  }

  @override
  void dispose() {
    // Stop API service
    _apiService.stopSendingData();

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
          right: 10,
          child: SensorDataWidget(
            bloodOxygen: bloodOxygen,
            heartRate: heartRate,
            bodyTemp: bodyTemp,
          ),
        ),

        // ✅ Floating Hang-Up Button
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
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.none,),
          ),
        ],
      ),
    );
  }
}