import 'package:PatientTabletApp/screen_saver/screen_saveradd.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:tablet_degim/screen_saver/screen_saveradd.dart';
import 'dart:math';
import 'dart:math' as math;

final String localUserID = math.Random().nextInt(10000).toString();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox'); // Open box once at startup
  await Firebase.initializeApp();
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




class PractoDoctorSearch extends StatefulWidget {
  const PractoDoctorSearch({super.key});

  @override
  _PractoDoctorSearchState createState() => _PractoDoctorSearchState();
}

class _PractoDoctorSearchState extends State<PractoDoctorSearch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding circles (Radar Effect)
              for (int i = 0; i < 3; i++)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value =
                    (_controller.value - (i * 0.3)).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: max(0, 1 - value),
                      child: Container(
                        width: screenWidth * 0.2 + (value * screenWidth * 0.7),
                        height: screenWidth * 0.2 + (value * screenWidth * 0.7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Centered content (Text → Image → Text)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Searching" text
                  Text(
                    'Searching',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.09), // Maintained spacing

                  // Stethoscope Image
                  Image.asset(
                    'assets/doctor/stethoscope.png',
                    width: screenWidth * 0.15, // Maintained original size
                  ),
                  SizedBox(height: screenHeight * 0.07), // Maintained spacing

                  // Success Message
                  Text(
                    'Your payment is successful!\nFinding you the best available doctor...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
