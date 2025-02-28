import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

// void main() => runApp(SerialPort());

class SerialPort extends StatefulWidget {
  const SerialPort({super.key});

  @override
  _SerialPort createState() => _SerialPort();
}

class _SerialPort extends State<SerialPort> {
  UsbPort? _port;
  String _status = "Searching for device...";
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  int bloodOxygen = 0;
  int heartRate = 0;
  double bodyTemp = 0.0;

  @override
  void initState() {
    super.initState();
    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _autoConnectDevice();
    });
    _autoConnectDevice();
  }

  Future<void> _autoConnectDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      await _connectTo(devices.first);
    } else {
      setState(() {
        _status = "No USB device found";
      });
    }
  }

  Future<bool> _connectTo(UsbDevice device) async {
    _disconnect();

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }

    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>,
        Uint8List.fromList([13, 10])
    );

    _subscription = _transaction!.stream.listen((String line) {
      _parseSerialData(line);
    });

    setState(() {
      _status = "Device Connected";
    });
    return true;
  }

  void _parseSerialData(String data) {
    List<String> values = data.split('|');
    if (values.length >= 3) {
      setState(() {
        bloodOxygen = int.tryParse(values[0]) ?? 0;
        heartRate = int.tryParse(values[1]) ?? 0;
        bodyTemp = double.tryParse(values[2]) ?? 0.0;
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

  @override
  void dispose() {
    super.dispose();
    _disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,

      // appBar: AppBar( centerTitle : true,title: Text( _status ,style: GoogleFonts.poppins(fontWeight: FontWeight.bold),)),
      body: SafeArea(
        child: SingleChildScrollView(
          child:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[

                const SizedBox(height: 450,),
                Text(_status, style: const TextStyle(color: Colors.white,fontSize: 10),),
                  _buildDataCard("Blood Oxygen", "$bloodOxygen%",),
                  _buildDataCard("Heart Rate", "$heartRate BPM"),
                  _buildDataCard("Body Temperature", "$bodyTemp °C"),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 5,
      color: Colors.black, // Set card background to black

      child: Padding(
        padding: const EdgeInsets.all(0),
        child: ListTile(

          title: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold,color: Colors.white, // Set title text color to white
          )),
          subtitle: Text(value, style:const TextStyle(fontSize: 8,color: Colors.white, // Set title text color to white
          )),
        ),
      ),
    );
  }
}
