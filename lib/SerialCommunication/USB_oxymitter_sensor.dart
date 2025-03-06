import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialPortService {
  static final SerialPortService _instance = SerialPortService._internal();

  factory SerialPortService() => _instance;

  SerialPortService._internal();

  UsbPort? _port;
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  final StreamController<Map<String, double>> _sensorDataController = StreamController.broadcast();
  Stream<Map<String, double>> get sensorDataStream => _sensorDataController.stream;

  /// ✅ Start listening for USB events and auto-connect
  Future<void> start() async {
    try {
      UsbSerial.usbEventStream?.listen((UsbEvent event) {
        print("USB Event: ${event.event}");
        _autoConnectDevice();
      });
      await _autoConnectDevice();
    } catch (e) {
      print("Error starting SerialPortService: $e");
    }
  }

  /// ✅ Auto-connects to the first available device
  Future<void> _autoConnectDevice() async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      if (devices.isNotEmpty) {
        print("Connecting to USB device: ${devices.first.productName}");
        await _connectTo(devices.first);
      } else {
        print("No USB devices found.");
      }
    } catch (e) {
      print("Error in auto-connect: $e");
    }
  }

  /// ✅ Connects to a USB device
  Future<bool> _connectTo(UsbDevice device) async {
    try {
      _disconnect(); // Ensure any previous connection is closed
      _port = await device.create();

      if (_port == null || !(await _port!.open())) {
        print("Failed to open port.");
        return false;
      }

      _device = device;
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

      _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>,
        Uint8List.fromList([13, 10]), // Line termination (CR + LF)
      );

      _subscription = _transaction!.stream.listen(
            (String line) => _parseSerialData(line),
        onError: (error) => print("Serial Port Error: $error"),
        onDone: () => print("Serial Port Disconnected."),
        cancelOnError: true,
      );

      print("Connected to ${device.productName}");
      return true;
    } catch (e) {
      print("Error connecting to USB device: $e");
      return false;
    }
  }

  /// ✅ Parses incoming serial data
  void _parseSerialData(String data) {
    try {
      data = data.trim(); // Remove extra spaces or new lines
      List<String> values = data.split('|');

      if (values.length < 3) {
        print("Invalid data received: $data");
        return;
      }

      double? bloodOxygen = double.tryParse(values[0]);
      double? heartRate = double.tryParse(values[1]);
      double? bodyTemp = double.tryParse(values[2]);

      if (bloodOxygen == null || heartRate == null || bodyTemp == null) {
        print("Data parsing failed: $data");
        return;
      }

      _sensorDataController.add({
        'bloodOxygen': bloodOxygen,
        'heartRate': heartRate,
        'bodyTemp': bodyTemp,
      });

      print("Parsed Data -> Oxygen: $bloodOxygen%, Heart Rate: $heartRate BPM, Temp: $bodyTemp°C");
    } catch (e) {
      print("Error parsing serial data: $e");
    }
  }

  /// ✅ Disconnects from USB and cleans up resources
  void _disconnect() {
    try {
      _subscription?.cancel();
      _subscription = null;
      _transaction?.dispose();
      _transaction = null;
      _port?.close();
      _port = null;
      _device = null;
      print("Serial port disconnected.");
    } catch (e) {
      print("Error during disconnect: $e");
    }
  }

  /// ✅ Disposes of all resources properly
  void dispose() {
    _disconnect();
    _sensorDataController.close();
  }
}
