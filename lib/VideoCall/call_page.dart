import 'dart:async';
import 'package:PatientTabletApp/APIServices/base_api.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../SerialCommunication/USB_oxymitter_sensor.dart';
import 'common.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:PatientTabletApp/thankyoupage/thankyoupage.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
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

  late Map<String, dynamic> prescriptionData;
  String? prescriptionId;

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

      // Make the GET request with Authorization header
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      // Check response status
      if (response.statusCode == 200) {

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          doctorName = data['doctor_name'] ?? 'Unknown Doctor';
          licenseNumber = data['license'] ?? '';
          prescriptions = List.from(data['prescriptions'] ?? []); // Ensure it's a List
          isLoading = false;
        });

        print('Prescription data fetched successfully: ${response.body}');
      } else {
        setState(() {
          errorMessage = 'No prescriptions found (Error ${response.statusCode})';
          isLoading = false;
        });
        print('Failed to fetch prescriptions: ${response.statusCode}');
        print('Response: ${response.body}');
        _showSnackBar('Failed to fetch prescriptions');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching prescriptions: $e';
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
  final dateFormat = DateFormat('dd-MM-yyyy');
  final timeFormat = DateFormat('HH:mm');
  final currentDate = DateTime.now();

  Future<void> _generatePrintPreview() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        maxPages: 10,  // Support multiple pages for long prescriptions
        build: (pw.Context context) {
          return [
            // Header - Reduced font sizes
            pw.Center(
              child: pw.Text(
                'BharatTeleClinic',
                style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'BharatTelePharma Pvt.Ltd.',
                style: const pw.TextStyle(fontSize: 25),
              ),
            ),

            pw.SizedBox(height: 2),
            pw.Divider(thickness: 3),
            pw.SizedBox(height: 2),

            // Doctor Details - Reduced font sizes and improved formatting
            pw.Center(child:  pw.Text('Doctor: $doctorName', style: const pw.TextStyle(fontSize: 20)), ),
            pw.Center(child:   pw.Text('License No: $licenseNumber', style: const pw.TextStyle(fontSize: 20)), ),

            pw.SizedBox(height: 2),
            pw.Divider(thickness:3),
            pw.SizedBox(height: 2),


            pw.Center(child:   pw.Text(
              'Date: ${dateFormat.format(currentDate)} | Time: ${timeFormat.format(currentDate)}',
              style: const pw.TextStyle(fontSize: 20),

            ), ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 3),
            pw.SizedBox(height: 2),

            // Prescription Header - Reduced font size
            pw.Text(
              'Medications',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 3),

            // Loop through prescriptions with optimized formatting
            ...prescriptions.map(
                  (prescription) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Drug: ${prescription['drug_name']}',
                      style: const pw.TextStyle(fontSize: 20, ),
                    ),
                    pw.Text(
                      'Dosage: ${prescription['dosage'] ?? ''} ${prescription['unit'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 20),
                      // Use maxLines and soft wrap to handle long texts
                      maxLines: 2,
                    ),
                    pw.Text(
                      'Duration: ${prescription['duration'] ?? ''} days',
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                    pw.Text(
                      'Frequency: ${getFrequencyPattern(prescription['frequency'])}',
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                    pw.Text(
                      'Instruction: ${prescription['instruction']}',
                      style: const pw.TextStyle(fontSize: 20),
                      // Use maxLines and soft wrap to handle long texts
                      maxLines: 3,
                    ),
                    pw.Text(
                      'Notes: ${prescription['notes']}',
                      style: const pw.TextStyle(fontSize: 20),
                      maxLines: 10,
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
            ),

            // pw.SizedBox(height: 5),

            // Signature - Right-aligned with smaller dimensions
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      // height: 15,
                      // width: 60,
                      child: pw.Text('Signature', style: const pw.TextStyle(fontSize: 15)),
                    ),
                    pw.Text(
                      "Dr.$doctorName",
                      style: const pw.TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 2),
            pw.Divider(thickness: 3),
            pw.SizedBox(height: 2),

            // Disclaimer with smaller font and word wrapping
            pw.Center(
              child: pw.Text(
                "This prescription is issued based on a teleconsultation. Consult your doctor in case of adverse reactions.",
                style: const pw.TextStyle(fontSize: 18),
                textAlign: pw.TextAlign.center,
              ),
            ),

            pw.SizedBox(height: 5),

            // Footer with reduced font size
            pw.Center(
              child: pw.Text(
                "THANK YOU! VISIT AGAIN!",
                style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,

              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                "hello@bharatteleclinic.co | +919581870076",
                style: const pw.TextStyle(fontSize: 18),
                textAlign: pw.TextAlign.center,

              ),
            ),
          ];
        },
      ),
    );

    // Show Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      // Force using our custom format
      // format: thermalPrinterFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              'No Data: $errorMessage',
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
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Card(
              // elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Doctor: $doctorName',
                      style: const TextStyle(
                        fontSize: 13,
                        // fontWeight: FontWeight.bold,
                        color: Color(0xFF243B6D),
                      ),
                    ),
                    if (licenseNumber.isNotEmpty)
                      Text(
                        'License: $licenseNumber',
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medications',
              style: TextStyle(
                fontSize: 15,
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
                          'Created: ${dateFormat.format(currentDate)} ${timeFormat.format(currentDate)}',
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: prescriptionData != null && prescriptionId != null
      //       ? () => printPrescription(prescriptionData!, prescriptionId!)
      //       : null, // Disable the button if data is missing
      //   backgroundColor: Color(0xFF243B6D),
      //   child: const Icon(Icons.print, color: Colors.white),
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _generatePrintPreview(),
        backgroundColor: const Color(0xFF243B6D),
        child: const Icon(Icons.print, color: Colors.white),
      ),





    );
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


  bool isMenuOpen = false; // Track if the menu is open

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

  void ShowPrescriptionDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Bharat Tele Clinic",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Color(0xFF243B6D)),
              textAlign: TextAlign.center, // Center-align the text
            ),
            // contentPadding: EdgeInsets.zero, // Removes default padding

            content: SizedBox(
              width: double.maxFinite,
              height: 300, // Adjust height as needed
              child: Column(
                children: [
                  // Prescription Screen
                  Expanded(
                    child: TabPrescriptionScreen(
                      sessionId: widget.sessionid,
                      token: widget.token,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Icon(
                    Icons.close, // Cross icon
                    color: Colors.black, // Change color if needed
                    size: 40, // Adjust size if necessary
                  ),
                ),
              ),

            ],
          );
        },
      );
    }

  }
  void _navigateToThankYouScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          token: widget.token,
          // Add any other parameters ThankYouPage needs
        ),
      ),
    );
  }

  bool _showOptions = false;

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
          events: ZegoUIKitPrebuiltCallEvents(
            onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
              _apiService.stopSendingData();
              sensorSubscription.cancel();
              _navigateToThankYouScreen();
            },
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

        // ✅ Floating Hang-Up Button
        Positioned(
          bottom: 5,
          left: MediaQuery.of(context).size.width / 2 - 35, // Centering horizontally
          child: Container(
            width: 70, // Ensuring a perfect circle
            height: 70, // Ensuring a perfect circle
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Making it circular
              color: Colors.white, // Background color
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.print, color: Color(0xFF243B6D)),
              onPressed: ShowPrescriptionDialog,
            ),
          ),
        ),


        // NEW FLOATING ACTION BUTTON WITH POPUP MENU (bottom right)
        Positioned(
            bottom: 5,
            right: 20,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            // Options that appear when menu is open
              if (_showOptions) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: Text("Store", style: TextStyle(fontSize: 12,decoration: TextDecoration.none,color: Color(0xFF243B6D))),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 'store',
                      mini: true,
                      onPressed: () {
                        print("Store clicked");
                      },
                      backgroundColor: Colors.white,
                      child: Icon(Icons.store,color: Color(0xFF243B6D)),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(

                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: Text("Other", style: TextStyle(fontSize: 12,decoration: TextDecoration.none,color: Color(0xFF243B6D))),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 'other',

                      mini: true,
                      onPressed: () {
                        print("Other clicked");
                      },
                      backgroundColor: Colors.white,
                      child: Icon(Icons.more_horiz,color: Color(0xFF243B6D)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],

              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _showOptions ? Icons.close : Icons.send,
                    color: Color(0xFF243B6D), // Match printer icon color
                  ),
                  onPressed: () {
                    setState(() {
                      _showOptions = !_showOptions;
                    });
                  },
                ),
              ),



            ],
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
      bottom: 90, // Adjust the position above the call button
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // ✅ Adjust width
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SensorCard(title: "Oxygen", value: "$bloodOxygen%", icon: Icons.bubble_chart, iconColor: Colors.blue,),
              SensorCard(title: "Heart Rate", value: "$heartRate BPM", icon: Icons.favorite, iconColor: Colors.red,),
              SensorCard(title: "Temp", value: "$bodyTemp °F", icon: Icons.thermostat, iconColor: Colors.orange,),
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
  final Color iconColor;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30), // Sensor Icon
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none,),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.none,),
          ),
        ],
      ),
    );
  }
}