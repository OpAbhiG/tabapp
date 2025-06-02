import 'dart:async';
import 'package:PatientTabletApp/APIServices/base_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../SerialCommunication/USB_oxymitter_sensor.dart';
import '../VideoCallDisaScreen/VdoCallDisScreen.dart';
import '../check connection/connectivityProvider.dart';
import 'common.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:PatientTabletApp/thankyoupage/thankyoupage.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;


import 'package:connectivity_plus/connectivity_plus.dart';





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
  // Data-related variables
  bool isLoading = true;
  List<dynamic> prescriptions = [];
  String doctorName = '';
  String licenseNumber = '';
  String errorMessage = '';

  // Printer-related variables
  UsbDevice? _printerDevice;
  UsbPort? _printerPort;
  bool _isPrinting = false;
  bool _isPrinterInitializing = false;
  bool _isPrinterConnected = false;
  final int _printerWidth = 384; // Width in dots for 58mm printer
  String _printerStatus = "Not initialized";
  // List<String> _debugMessages = [];
  // final int _maxDebugMessages = 15;

  // Date formatting
  final dateFormat = DateFormat('dd-MM-yyyy');
  final timeFormat = DateFormat('HH:mm');
  final currentDate = DateTime.now();


  // Add this variable with your other class variables
  String signatureUrl = '';


  @override
  void initState() {
    super.initState();
    fetchPrescriptionData();

    // Initialize printer connection during screen load
    _initPrinterConnection();
  }

  @override
  void dispose() {
    // Close printer connection when screen is disposed
    if (_printerPort != null) {
      try {
        _printerPort!.close();
      } catch (e) {
        print("Error closing printer port: $e");
      }
      _printerPort = null;
    }
    super.dispose();
  }

  // void _showSnackBar(String message, {Duration? duration}) {
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(message),
  //         duration: duration ?? const Duration(seconds: 2),
  //         behavior: SnackBarBehavior
  //             .floating, // Make it float to be less intrusive
  //       ),
  //     );
  //   }
  // }

  void _showSnackBar(String message, {Duration? duration}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration ?? const Duration(seconds: 1), // Short duration
          behavior: SnackBarBehavior.floating, // Float above content
          margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20), // Position above FAB
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
        ),
      );
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

  Future<void> fetchPrescriptionData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Build the URL with query parameters
      final Uri uri = Uri.parse('$baseapi/tab/get_drug_list_by_session')
          .replace(queryParameters: {'session_id': widget.sessionId});

      print("-------------------- $uri --------------------");

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

        print("-------------------- $data --------------------");
        setState(() {
          doctorName = data['doctor_name'] ?? 'Unknown Doctor';
          licenseNumber = data['license'] ?? '';
          prescriptions = List.from(data['prescriptions'] ?? []); // Ensure it's a List
          // Build complete signature URL with hardcoded CloudFront URL
          String signaturePath = data['signature'] ?? '';
          if (signaturePath.isNotEmpty) {
            // Extract just the filename from the path (remove doctor_sign/ prefix if present)
            String fileName = signaturePath.startsWith('https://d116q8t0apa2jk.cloudfront.net/doctor_sign/')
                ? signaturePath.substring('doctor_sign/'.length)
                : signaturePath;
            signatureUrl = 'https://d116q8t0apa2jk.cloudfront.net/doctor_sign/$fileName';
          } else {
            signatureUrl = '';
          }
          isLoading = false;
        });
        print('Signature URL: $signatureUrl');

        print('Prescription data fetched successfully: ${response.body}');
      } else {
        setState(() {
          errorMessage =
          'No prescriptions found (Error ${response.statusCode})';
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

  // Show debug messages on screen

//   void _addDebugMessage(String message) {
//     setState(() {
//       _debugMessages.add(
//           "[${DateTime.now().toString().substring(11, 19)}] $message");
//       // Keep only the last N messages
//       if (_debugMessages.length > _maxDebugMessages) {
//         _debugMessages.removeAt(0);
//       }
//     });
//     print(message); // Also print to console
//   }


  void _addDebugMessage(String message) {
    // Just print to console,
    print("Printer: $message");
  }


// Show a more visible message dialog
  void _showMessageDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }



// Initialize the printer with direct USB approach
  Future<void> _initPrinterConnection() async {
    if (_isPrinterInitializing) {
      _addDebugMessage("Printer initialization already in progress");
      return;
    }

    setState(() {
      _isPrinterInitializing = true;
      _printerStatus = "Connecting...";
    });

    _addDebugMessage("Starting printer connection");

    try {
      // Close existing connection if any
      if (_printerPort != null) {
        try {
          await _printerPort!.close();
          _addDebugMessage("Closed existing connection");
        } catch (e) {
          _addDebugMessage("Error closing port: $e");
        }
        _printerPort = null;
      }

      // List available devices
      _addDebugMessage("Listing USB devices");
      List<UsbDevice> devices = await UsbSerial.listDevices();

      if (devices.isEmpty) {
        _addDebugMessage("No USB devices found");
        setState(() {
          _isPrinterConnected = false;
          _printerStatus = "No USB devices";
        });
        return;
      }

      // Log all found devices
      _addDebugMessage("Found ${devices.length} USB devices:");
      for (var device in devices) {
        _addDebugMessage("VID:${device.vid}, PID:${device.pid}");
      }

      _addDebugMessage("Looking for printer with VID:4070, PID:33054");
      _printerDevice = null;

      for (var device in devices) {
        if (device.vid == 4070 && device.pid == 33054) {
          _printerDevice = device;
          _addDebugMessage("Found printer device matching exact VID/PID");
          break;
        }
      }

      // If specific device not found, try any device
      if (_printerDevice == null && devices.isNotEmpty) {
        _printerDevice = devices.first;
        _addDebugMessage("Using first available device: VID:${devices.first.vid}, PID:${devices.first.pid}");
      }

      if (_printerDevice == null) {
        _addDebugMessage("No devices available");
        setState(() {
          _isPrinterConnected = false;
          _printerStatus = "No printer found";
        });
        return;
      }

      // Try direct USB printing approach using our native plugin
      try {
        _addDebugMessage("Trying direct USB printing approach");

        const platform = MethodChannel('com.bharatteleclinic/usb_printer');

        final bool success = await platform.invokeMethod('printTest', {
          'vendorId': _printerDevice!.vid,
          'productId': _printerDevice!.pid,
        });

        _addDebugMessage("Direct USB print test result: $success");

        if (success) {
          setState(() {
            _isPrinterConnected = true;
            _printerStatus = "Connected (Direct USB)";
          });
          _addDebugMessage("Printer connected using direct USB");
          return;
        } else {
          _addDebugMessage("Direct USB test command failed");
        }
      } catch (e) {
        _addDebugMessage("Direct USB approach failed: $e");
      }

      // If direct USB approach failed, we'll try with UsbSerial as fallback
      _addDebugMessage("Falling back to UsbSerial approach");
      try {
        _printerPort = await _printerDevice!.create();
        if (_printerPort == null) {
          _addDebugMessage("Failed to create port");
          setState(() {
            _isPrinterConnected = false;
            _printerStatus = "Port creation failed";
          });
          return;
        }

        bool opened = false;
        try {
          _addDebugMessage("Attempting to open port");
          opened = await _printerPort!.open();
          _addDebugMessage("Port open result: $opened");
        } catch (e) {
          _addDebugMessage("Error opening port: $e");
          opened = false;
        }

        if (!opened) {
          _addDebugMessage("Failed to open port");
          setState(() {
            _isPrinterConnected = false;
            _printerStatus = "Port open failed";
          });
          return;
        }

        // Configure port with EP-300 settings
        _addDebugMessage("Configuring with 9600,8,N,1");
        try {
          await _printerPort!.setDTR(true);
          await _printerPort!.setRTS(true);

          await _printerPort!.setPortParameters(
              9600,
              UsbPort.DATABITS_8,
              UsbPort.STOPBITS_1,
              UsbPort.PARITY_NONE
          );

          setState(() {
            _isPrinterConnected = true;
            _printerStatus = "Connected (Serial)";
          });
          _addDebugMessage("Printer connected via serial");
        } catch (e) {
          _addDebugMessage("Port configuration failed: $e");
          setState(() {
            _isPrinterConnected = false;
            _printerStatus = "Configuration failed";
          });
        }
      } catch (e) {
        _addDebugMessage("UsbSerial approach failed: $e");
        setState(() {
          _isPrinterConnected = false;
          _printerStatus = "Serial failed";
        });
      }
    } catch (e) {
      _addDebugMessage("Initialization error: $e");
      setState(() {
        _isPrinterConnected = false;
        _printerStatus = "Init failed";
      });
    } finally {
      setState(() {
        _isPrinterInitializing = false;
      });
      _addDebugMessage("Initialization completed. Connected: $_isPrinterConnected");
    }
  }



  // Helper method to handle text wrapping for narrow paper

  Future<void> printDirectToThermalPrinter() async {
    if (_isPrinting) {
      _addDebugMessage("Print already in progress");
      return;
    }

    setState(() {
      _isPrinting = true;
    });
    _addDebugMessage("Starting print job");

    try {

      if (!_isPrinterConnected) {
        _addDebugMessage("Printer not connected, initializing");
        _showSnackBar("Connecting to printer...");
        await _initPrinterConnection();

        if (!_isPrinterConnected) {
          _addDebugMessage("Failed to connect printer");
          _showSnackBar("Could not connect to printer");
          setState(() {
            _isPrinting = false;
          });
          return;
        }
      }

      _addDebugMessage("Preparing print data");
      _showSnackBar("Printing...");

      // Load capability profile
      final profile = await CapabilityProfile.load();


      final generator = Generator(PaperSize.mm58, profile);

      // Initialize printer command buffer
      List<int> bytes = [];

      // Reset printer
      bytes.addAll(generator.reset());

      // Center alignment for header
      bytes.addAll(
          generator.setStyles(const PosStyles(align: PosAlign.center)));

      // Print header
      bytes.addAll(generator.text('BharatTeleClinic',
          styles: const PosStyles(bold: true,
              height: PosTextSize.size2,
              width: PosTextSize.size2)));
      bytes.addAll(generator.text('BharatTelePharma Pvt.Ltd.'));
      bytes.addAll(generator.hr());

      // Print doctor details
      bytes.addAll(generator.text('Doctor: ${doctorName.trim()}'));
      if (licenseNumber.isNotEmpty) {
        bytes.addAll(generator.text('License: ${licenseNumber.trim()}'));
      }

      // Date and time
      bytes.addAll(generator.text('Date: ${dateFormat.format(currentDate)}'));
      bytes.addAll(generator.text('Time: ${timeFormat.format(currentDate)}'));
      bytes.addAll(generator.hr());

      // Left alignment for prescription details
      bytes.addAll(generator.setStyles(const PosStyles(align: PosAlign.left)));

      // Print medications header
      bytes.addAll(
          generator.text('MEDICATIONS', styles: const PosStyles(bold: true)));

      // Print each medication
      for (var prescription in prescriptions) {
        // Drug name in bold
        String drugName = prescription['drug_name']?.toString() ??
            'Unknown Medication';
        bytes.addAll(
            generator.text(drugName, styles: const PosStyles(bold: true)));

        // Add dosage information
        if (prescription['dosage'] != null) {
          String dosage = prescription['dosage']?.toString() ?? '';
          String unit = prescription['unit']?.toString() ?? '';
          bytes.addAll(generator.text('Dosage: $dosage $unit'));
        }

        String frequency = getFrequencyPattern(prescription['frequency']);
        bytes.addAll(generator.text('Freq: $frequency'));

        String duration = prescription['duration']?.toString() ?? '0';
        bytes.addAll(generator.text('Duration: $duration days'));

        // Handle long text fields with proper wrapping
        String? instruction = prescription['instruction']?.toString();
        if (instruction != null && instruction.isNotEmpty) {
          addWrappedText(bytes, generator, 'Instruction:', instruction,
              maxCharsPerLine: 24);
        }

        String? notes = prescription['notes']?.toString();
        if (notes != null && notes.isNotEmpty) {
          addWrappedText(
              bytes, generator, 'Notes:', notes, maxCharsPerLine: 24);
        }

        // Separator between medications
        bytes.addAll(generator.hr());
      }


      // Signature
      bytes.addAll(generator.setStyles(const PosStyles(align: PosAlign.right)));
      bytes.addAll(generator.text('Signature'));

      // Try to print signature image if available
      if (signatureUrl.isNotEmpty) {
        try {
          _addDebugMessage("Attempting to print signature image");

          // Download signature image
          final response = await http.get(
            Uri.parse(signatureUrl),
            // No authorization needed for CloudFront URLs
          );

          if (response.statusCode == 200) {
            // Decode image
            final img.Image? originalImage = img.decodeImage(response.bodyBytes);

            if (originalImage != null) {
              // Resize image to fit thermal printer width (max ~384 pixels for 58mm)
              final img.Image resizedImage = img.copyResize(
                originalImage,
                width: 200, // Adjust based on your printer's capability
                height: (originalImage.height * 200 / originalImage.width).round(),
              );

              // Convert to 1-bit black and white
              final img.Image bwImage = img.copyResize(resizedImage, width: 200);

              // Print signature label
              bytes.addAll(generator.text('Doctor Signature:'));
              bytes.addAll(generator.feed(1));

              // Print image
              bytes.addAll(generator.imageRaster(bwImage, align: PosAlign.right));
              bytes.addAll(generator.feed(1));

              _addDebugMessage("Signature image added to print data");
            } else {
              _addDebugMessage("Failed to decode signature image");
              // Fallback to text signature
              bytes.addAll(generator.text('Signature'));
              bytes.addAll(generator.feed(2)); // Space for manual signature
            }
          } else {
            _addDebugMessage("Failed to download signature image: ${response.statusCode}");
            // Fallback to text signature
            bytes.addAll(generator.text('Signature'));
            bytes.addAll(generator.feed(2)); // Space for manual signature
          }
        } catch (e) {
          _addDebugMessage("Error processing signature image: $e");
          // Fallback to text signature
          bytes.addAll(generator.text('Signature'));
          bytes.addAll(generator.feed(2)); // Space for manual signature
        }
      } else {
        // No signature URL, just print text
        bytes.addAll(generator.text('Signature'));
        bytes.addAll(generator.feed(2)); // Space for manual signature
      }

      bytes.addAll(generator.text('Dr. ${doctorName.trim()}'));


      // Disclaimer and footer
      bytes.addAll(
          generator.setStyles(const PosStyles(align: PosAlign.center)));
      bytes.addAll(generator.feed(1));

      String disclaimer = "This prescription is issued based on a teleconsultation. Consult your doctor in case of adverse reactions.";
      addWrappedText(bytes, generator, '', disclaimer, maxCharsPerLine: 24);

      bytes.addAll(generator.feed(1));
      bytes.addAll(generator.text(
          'THANK YOU! VISIT AGAIN!', styles: const PosStyles(bold: true)));
      bytes.addAll(generator.text('admin@bharatteleclinic.co'));
      bytes.addAll(generator.text('+919581870076'));

      // Feed paper and cut
      bytes.addAll(generator.feed(3));
      bytes.addAll(generator.cut());

      // First try direct USB printing
      _addDebugMessage("Sending data to printer (${bytes.length} bytes)");

      // Use direct USB approach for most reliable printing
      try {
        const platform = MethodChannel('com.bharatteleclinic/usb_printer');

        // First ensure we have the right device - mostly for logging purposes
        if (_printerDevice == null) {
          _addDebugMessage("No printer device selected");
          throw Exception("No printer device selected");
        }

        _addDebugMessage(
            "Sending to device VID:${_printerDevice!.vid}, PID:${_printerDevice!
                .pid}");

        final bool success = await platform.invokeMethod('printData', {
          'vendorId': _printerDevice!.vid,
          'productId': _printerDevice!.pid,
          'data': Uint8List.fromList(bytes),
        });

        if (success) {
          _addDebugMessage("Print successful via direct USB");
          _showSnackBar("Printed successfully");
        } else {
          _addDebugMessage("Direct USB printing returned false");
          throw Exception("Direct USB printing failed");
        }
      } catch (e) {
        _addDebugMessage("Direct USB printing failed: $e");

        // Fall back to serial port approach if available
        if (_printerPort != null && _printerStatus.contains("Serial")) {
          _addDebugMessage("Falling back to serial port printing");

          try {
            // Send data in chunks
            const int chunkSize = 256; // Smaller chunks for potentially limited buffer
            final Uint8List data = Uint8List.fromList(bytes);

            int totalChunks = (data.length / chunkSize).ceil();

            for (int i = 0; i < data.length; i += chunkSize) {
              int end = (i + chunkSize < data.length) ? i + chunkSize : data
                  .length;
              Uint8List chunk = data.sublist(i, end);

              int chunkNumber = (i ~/ chunkSize) + 1;
              _addDebugMessage(
                  "Sending chunk $chunkNumber of $totalChunks (${chunk
                      .length} bytes)");

              await _printerPort!.write(chunk);

              // Longer delay between chunks
              await Future.delayed(const Duration(milliseconds: 200));
            }

            _addDebugMessage("Print successful via serial port");
            _showSnackBar("Printed successfully");
          } catch (serialError) {
            _addDebugMessage("Serial printing failed: $serialError");
            _showSnackBar("Printing failed");
          }
        } else {
          _showSnackBar("Printing failed. Please reconnect printer.");
        }
      }
    } catch (e) {
      _addDebugMessage("Print job failed: $e");
      _showSnackBar("Print error: ${e.toString().split(',')[0]}");
    } finally {
      setState(() {
        _isPrinting = false;
      });
      _addDebugMessage("Print job process ended");
    }
  }

// Helper method to handle text wrapping for narrow paper
  void addWrappedText(List<int> bytes, Generator generator, String label,
      String text, {int maxCharsPerLine = 24}) {
    // First add the label if provided
    if (label.isNotEmpty) {
      bytes.addAll(generator.text(label));
    }

    // Split long text into multiple lines
    for (int i = 0; i < text.length; i += maxCharsPerLine) {
      int end = (i + maxCharsPerLine < text.length) ? i + maxCharsPerLine : text
          .length;

      // Look for a space to break at if possible
      if (end < text.length && text[end] != ' ') {
        int lastSpace = text.substring(i, end).lastIndexOf(' ');
        if (lastSpace > 0) {
          end = i + lastSpace + 1;
        }
      }

      // Add indentation for wrapped text
      bytes.addAll(generator.text('  ${text.substring(i, end).trim()}'));
    }
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [


                    Text(
                      'Doctor: $doctorName',
                      style: const TextStyle(
                        fontSize: 13,
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
            // Add signature display section
            if (signatureUrl.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doctor Signature:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF243B6D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 80,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            signatureUrl,
                            fit: BoxFit.contain,
                            headers: {'Authorization': 'Bearer ${widget.token}'},
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Signature not available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctorName.trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),




      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isPrinting) {
            _showSnackBar("Print job already in progress");
            return;
          }

          if (!_isPrinterConnected) {
            _showPrinterAlert("Printer Not Connected",
                "Printer is not connected. Would you like to connect now?");
          } else {
            printDirectToThermalPrinter();
          }
        },
        backgroundColor: _isPrinting
            ? Colors.grey
            : _isPrinterConnected
            ? const Color(0xFF243B6D)
            : Colors.orange,
        child: _isPrinting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(
            _isPrinterConnected ? Icons.print : Icons.print_disabled,
            color: Colors.white
        ),
      ),
    );
  }

// Helper method for printer alerts
  void _showPrinterAlert(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initPrinterConnection().then((_) {
                  if (_isPrinterConnected) {
                    printDirectToThermalPrinter();
                  }
                });
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
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

  // Add SensorApiService instance
  late SensorApiService _apiService;



  //dr details
  String doctorName = "";
  String doctorQualification = "";
  String doctorSpeciality = "";


  ///check internet connect
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;







  ////need update
  // String doctorImageUrl="";

  Timer? _autoNavigationTimer; // New timer for auto navigation after 2 minutes
  Timer? _disconnectionCheckTimer; // Timer to check for prolonged disconnection
  bool _hasNavigatedDueToDisconnection = false; // Flag to prevent multiple navigations





  @override
  void initState() {
    super.initState();



    // Initialize the API service with token and session ID
    _apiService = SensorApiService(
      baseUrl: baseapi,
      token: widget.token,
      sessionId: widget.sessionid,
    );

    _loadDoctorDetails(); //  load details

    SerialPortService().start(); // ✅ Start SerialPort service
    _startListeningToSensor();

    // Start sending data to API
    _apiService.startSendingData(
          () => bloodOxygen,
          () => heartRate,
          () => bodyTemp,
    );

    // Start the 2-minute timer for auto navigation
    _startAutoNavigationTimer();

    // Start monitoring internet connectivity
    _startConnectivityMonitoring();
  }


// New method to start the 2-minute auto navigation timer
  void _startAutoNavigationTimer() {
    _autoNavigationTimer = Timer(const Duration(minutes: 2), () {
      if (mounted && !_hasNavigatedDueToDisconnection) {
        print('2 minutes elapsed, automatically navigating...');
        _navigateToDisconnectedScreen();
      }
    });
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final bool isConnected = !result.contains(ConnectivityResult.none);

      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        if (!isConnected) {
          print('Internet disconnected, starting disconnection check timer...');
          _startDisconnectionCheckTimer();
        } else {
          print('Internet reconnected, canceling disconnection check timer...');
          _disconnectionCheckTimer?.cancel();
        }
      }
    });
  }

  // Timer to check if disconnection persists for too long
  void _startDisconnectionCheckTimer() {
    _disconnectionCheckTimer?.cancel(); // Cancel any existing timer

    _disconnectionCheckTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isConnected && !_hasNavigatedDueToDisconnection) {
        print('Internet disconnected for 10 seconds, navigating to disconnected screen...');
        _hasNavigatedDueToDisconnection = true;
        _navigateToDisconnectedScreen();
      }
    });
  }

  Future<void> _loadDoctorDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorName = prefs.getString('doctor_name') ?? 'Doctor';
      doctorQualification = prefs.getString('doctor_qualification') ?? '';
      doctorSpeciality = prefs.getString('doctor_speciality') ?? '';





      // doctorImageUrl = prefs.getString('doctorImageUrl') ?? '';












    });
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

  void showPrescriptionDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Bharat Tele Clinic",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243B6D)),
              textAlign: TextAlign.center,
            ),
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
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }




  Timer? _navigationTimer;


  // void _navigateToThankYouScreen() {
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(
  //       builder: (context) => BookingConfirmationScreen(
  //         token: widget.token,
  //       ),
  //     ),
  //   );
  // }

// Navigate specifically for disconnection scenario
// Navigate specifically for disconnection scenario
  void _navigateToDisconnectedScreen() async {
    // Cancel all timers
    _autoNavigationTimer?.cancel();
    _disconnectionCheckTimer?.cancel();

    try {
      // Try to call the API (might fail due to no internet)
      Map<String, dynamic>? response;
      try {
        response = await _getLastConnectedDoctor();
      } catch (e) {
        print('API call failed due to no internet: $e');
        response = null;
      }

      if (mounted) {
        // Extract session ID safely with proper null checking
        String sessionId;
        if (response != null &&
            response['data'] != null &&
            response['data']['session_id'] != null) {
          sessionId = response['data']['session_id'].toString();
        } else {
          sessionId = widget.sessionid;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VideoCallDisconnectedScreen(
              token: widget.token,
              doctorDetails: response?['data'],
              sessionId: sessionId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in _navigateToDisconnectedScreen: $e');


    }
  }
  Future<void> _navigateToThankYouScreen() async {
    // Cancel the auto navigation timer if it's still running
    _autoNavigationTimer?.cancel();

    // Prevent navigation if already navigated due to disconnection
    if (_hasNavigatedDueToDisconnection) {
      return;
    }

    try {
      // Call get last connected doctor API
      final response = await _getLastConnectedDoctor();
      final isConnected = _isConnected;

      if (response['statusCode'] == 200 || !isConnected) {
        // Navigate to VideoCallDisconnectedScreen with doctor details
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VideoCallDisconnectedScreen(
                token: widget.token,
                doctorDetails: response['data'],
                sessionId: response['data']['session_id']?.toString() ?? widget.sessionid,
              ),
            ),
          );
        }
      } else {
        // Navigate to BookingConfirmationScreen as fallback
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BookingConfirmationScreen(
                token: widget.token,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting last connected doctor: $e');
      // Navigate to BookingConfirmationScreen as fallback
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              token: widget.token,
            ),
          ),
        );
      }
    }
  }
  // Method to call get last connected doctor API
// Method to call get last connected doctor API
  Future<Map<String, dynamic>> _getLastConnectedDoctor() async {
    try {
      final response = await http.get(
        Uri.parse('$baseapi/patient/get_last_connected_doctor'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        return {
          'statusCode': response.statusCode,
          'data': decodedBody,
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'data': null,
        };
      }
    } catch (e) {
      print('Failed to get last connected doctor: $e');
      // Return a proper Map structure even on error
      return {
        'statusCode': 0, // or some error code
        'data': null,
      };
    }
  }
  @override
  void dispose() {
    _navigationTimer?.cancel();

    _autoNavigationTimer?.cancel(); // Cancel the auto navigation timer
    _disconnectionCheckTimer?.cancel(); // Cancel the disconnection check timer
    _connectivitySubscription.cancel(); // Cancel connectivity subscription

    // Stop API service
    _apiService.stopSendingData();

    // Cancel sensor subscription
    sensorSubscription.cancel();

    // Provider.of<ConnectivityProvider>(context, listen: false).disposeStream();

    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    //
    // final isConnected = Provider.of<ConnectivityProvider>(context).isConnected;
    //
    // if (!isConnected) {
    //   return const VideoCallDisconnectedScreen(); // custom widget to show offline message
    // }

    final isTablet = MediaQuery.of(context).size.shortestSide >= 700;
    final topPadding = MediaQuery.of(context).padding.top + (isTablet ? 20 : 10);

    Widget doctorInfoHeader() {
      return Positioned(
        top: topPadding,
        left: isTablet ? 20 : 12,
        right: isTablet ? null : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : MediaQuery.of(context).size.width - 24,
          ),
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "https://example.com/image.jpg", // e.g., 'doctorImageUrl'
                  width: isTablet ? 70 : 50,
                  height: isTablet ? 70 : 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: isTablet ? 70 : 50, color: Colors.white54),
                ),
              ),
              const SizedBox(width: 12),
              // Doctor Name and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$doctorQualification, $doctorSpeciality',
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: isTablet ? 16 : 13,
                        color: Colors.white70,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }


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

        // Floating Print Button
        Positioned(
          bottom: 5,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: Container(
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
              icon: const Icon(Icons.print, color: Color(0xFF243B6D)),
              onPressed: showPrescriptionDialog,
            ),
          ),
        ),


        //dr details
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: doctorInfoHeader(),
        ),


      ],
    );
  }
}

/// Sensor Data Display Widget
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
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SensorCard(title: "Oxygen", value: "$bloodOxygen%", icon: Icons.bubble_chart, iconColor: Colors.blue),
            SensorCard(title: "Heart Rate", value: "$heartRate BPM", icon: Icons.favorite, iconColor: Colors.red),
            SensorCard(title: "Temp", value: "$bodyTemp °F", icon: Icons.thermostat, iconColor: Colors.orange),
          ],
        ),
      ),
    );
  }
}
/// Individual Sensor Card Widget
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
            style: const TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}




