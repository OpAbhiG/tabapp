import 'dart:convert';
import 'package:PatientTabletApp/check%20connection/connectivityProvider.dart';

import 'package:PatientTabletApp/screen_saver/screen_saveradd.dart';
import 'package:PatientTabletApp/sliding_Card/Sliding_Card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'APIServices/base_api.dart';
import 'VideoCall/call_page.dart';
import 'VideoCallDisaScreen/NoInternetScreen.dart';

final String localUserID = math.Random().nextInt(10000).toString();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox'); // Open box once at startup
  await Firebase.initializeApp();
  await requestPermissions();
  runApp(
    ChangeNotifierProvider(
        create: (_) => ConnectivityProvider(),
        child:const MyApp(),
      ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // darkTheme: ThemeData.dark(),
      home: SplashScreen(),

    );
  }
}

//permission screeen display
Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.camera,
    Permission.microphone,
  ].request();

  if (statuses[Permission.location]!.isDenied ||
      statuses[Permission.camera]!.isDenied ||
      statuses[Permission.microphone]!.isDenied) {
    print("One or more permissions were denied.");
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }


  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Add a small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ImageCarousel()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/btclogo.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Medical Store App',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;


  String? enterpriseId;

  Future<void> _sendOtp() async {
    final String phone = _userIdController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar("Please enter your phone number");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseapi/user/enterprise_gen_otp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"number": phone}),
      );

      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && data['enterprise_id'] != null) {
        enterpriseId = data['enterprise_id'].toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('enterprise_id', enterpriseId!);
        await prefs.setString('phone', phone);

        _showSnackBar("OTP sent to $phone");
      } else {
        _showSnackBar("Failed to send OTP: ${data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final String phone = _userIdController.text.trim();
    final String otp = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedEnterpriseId = prefs.getString('enterprise_id');

      final url = Uri.parse("$baseapi/user/enter_verify_otp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "number": phone,
          "otp": otp,
          "enterprise_id": savedEnterpriseId,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      final Map<String, dynamic> dcode = jsonDecode(response.body);

      print("Decoded response: $dcode");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 && data['access_token'] != null) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('access_token', data['access_token']);

        // ✅ SAVE ENTERPRISE_ID FROM API RESPONSE - Add this part
        if (data.containsKey('enterprise_id')) {
          await prefs.setString('enterprise_id', data['enterprise_id'].toString());
          print("✅ Enterprise ID saved: ${data['enterprise_id']}");
        } else if (data.containsKey('user') && data['user'].containsKey('enterprise_id')) {
          // Some APIs return enterprise_id inside user object
          await prefs.setString('enterprise_id', data['user']['enterprise_id'].toString());
          print("✅ Enterprise ID saved from user object: ${data['user']['enterprise_id']}");
        } else {
          print("⚠️ Enterprise ID not found in API response");
          // Check what fields are available in the response
          print("Available fields: ${data.keys.toList()}");
        }


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ImageCarousel()),
        );
      } else {
        _showSnackBar("$data");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Error: $e");
    }
  }


// ✅ HELPER FUNCTION TO CHECK WHAT'S SAVED IN SHAREDPREFERENCES
  Future<void> debugSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    print("🔍 DEBUG: All SharedPreferences data:");
    for (String key in keys) {
      dynamic value = prefs.get(key);
      print("🔑 $key: $value (${value.runtimeType})");
    }
  }

// ✅ ALTERNATIVE: If enterprise_id is not in API response, save it during initial setup
  Future<void> saveEnterpriseIdManually(String enterpriseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('enterprise_id', enterpriseId);
    print("✅ Manual Enterprise ID saved: $enterpriseId");
  }

// ✅ FUNCTION TO CLEAR ALL SHARED PREFERENCES (for debugging)
  Future<void> clearAllSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("🗑️ All SharedPreferences cleared");
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = Provider.of<ConnectivityProvider>(context).isConnected;

    if (!isConnected) {
      return const NoInternetScreen(); // custom widget to show offline message
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/btclogo.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),


                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Replace 'SignInScreen()' with your actual screen class
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SpecialitiesScreen()),
                    );
                  },
                  child: Text(
                    'bypass',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),



                const SizedBox(height: 10),
                Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                // Phone field
                Container(
                  decoration: _boxDecoration(),
                  child: TextFormField(
                    controller: _userIdController,
                    keyboardType: TextInputType.number, // 👈 Set number keyboard
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // 👈 Allow only digits
                      LengthLimitingTextInputFormatter(10),   // 👈 Limit to 10 digits
                    ],
                    decoration: _inputDecoration('Enter Number', Icons.phone),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your number';
                      } else if (value.length != 10) {
                        return 'Number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                // OTP field
                Container(
                  decoration: _boxDecoration(),
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.number, // 👈 Set number keyboard
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // 👈 Allow only digits
                    ],
                    decoration: _inputDecoration('Enter OTP', Icons.sms),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter otp' : null,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: const Text('Get OTP', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 10),
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtpAndLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    )
                        : const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.red),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }


  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    Provider.of<ConnectivityProvider>(context, listen: false).disposeStream();
    super.dispose();
  }
}