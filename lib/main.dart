import 'package:PatientTabletApp/screen_saver/screen_saveradd.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

final String localUserID = math.Random().nextInt(10000).toString();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox'); // Open box once at startup
  await Firebase.initializeApp();
  await requestPermissions();
    runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // darkTheme: ThemeData.dark(),
      // home---> ImageCarousel(),//
      home: ImageCarousel(),

    );
  }
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.audio
  ].request();

  if (statuses[Permission.location]!.isDenied ||
      statuses[Permission.camera]!.isDenied ||
      statuses[Permission.microphone]!.isDenied) {
    print("One or more permissions were denied.");
  }
}


