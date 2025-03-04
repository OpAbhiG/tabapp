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

  Future<void> start() async {
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      _autoConnectDevice();
    });
    _autoConnectDevice();
  }

  Future<void> _autoConnectDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      await _connectTo(devices.first);
    }
  }

  Future<bool> _connectTo(UsbDevice device) async {
    _disconnect();
    _port = await device.create();

    if (await (_port!.open()) != true) {
      return false;
    }

    _device = device;
    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
      _port!.inputStream as Stream<Uint8List>,
      Uint8List.fromList([13, 10]),
    );

    _subscription = _transaction!.stream.listen((String line) {
      _parseSerialData(line);
    });

    return true;
  }

  void _parseSerialData(String data) {
    List<String> values = data.split('|');
    if (values.length >= 3) {
      _sensorDataController.add({
        'bloodOxygen': double.tryParse(values[0]) ?? 0,
        'heartRate': double.tryParse(values[1]) ?? 0,
        'bodyTemp': double.tryParse(values[2]) ?? 0.0,
      });
    }
  }

  void _disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _transaction?.dispose();
    _transaction = null;
    _port?.close();
    _port = null;
    _device = null;
  }

  void dispose() {
    _disconnect();
    _sensorDataController.close();
  }
}
