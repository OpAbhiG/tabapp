import 'package:flutter/material.dart';
import '../APIServices/base_api.dart';
import '../signin_signup/otp_login.dart';
import '../topSection/topsection.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//v2

class SpecialitiesScreen extends StatefulWidget {
  const SpecialitiesScreen({super.key});

  @override
  State<SpecialitiesScreen> createState() => _SpecialitiesScreenState();
}

class _SpecialitiesScreenState extends State<SpecialitiesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _hasShownHint = false;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Create slide animation
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0), // Slight horizontal movement
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Stop and reset animation after initial hint
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _animationController.stop();
        setState(() {
          _hasShownHint = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Future<List<Map<String, dynamic>>> fetchSpecialities() async {
  //   final response = await http.get(Uri.parse("$baseapi/tab/tb-speciality"));
  //
  //   if (response.statusCode == 200) {
  //     print(jsonDecode(response.body));
  //     print("Response Status Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");
  //
  //     final data = json.decode(response.body);
  //     return List<Map<String, dynamic>>.from(data["specialities"]);
  //   } else {
  //     throw Exception("Failed to load specialities");
  //   }
  // }
  Future<List<Map<String, dynamic>>> fetchSpecialities() async {
    try {
      final response = await http.get(Uri.parse("$baseapi/tab/tb-speciality"));

      if (response.statusCode == 200) {

        print(jsonDecode(response.body));
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        final decodedData = json.decode(response.body);
        if (decodedData != null && decodedData["specialities"] is List) {
          return List<Map<String, dynamic>>.from(decodedData["specialities"]);
        }
      }
      throw Exception("Invalid data format");
    } catch (e) {
      debugPrint("Error fetching specialities: $e");
      throw Exception("Failed to load specialities");
    }
  }

  final Map<String, List<Map<String, dynamic>>> concerns = {
    "General Physician": [{"title": "Stomach pain", "image": 'assets/g1.1.jpg'}],
    " Gynecologist": [{"title": "Period problems", "image": 'assets/gy1.1.jpg'}],
    "Dermatologist": [{"title": "Acne Scars", "image": 'assets/d1.1.jpg'}],
    "Sexologist": [{"title": "HIV Aids","image": "assets/s1.1.jpg"}],
    "Psychiatrist": [{"title": "Autism", "image": 'assets/psy1.1.jpg'}],
    "Gastroenterologist": [{"title": "Indigestion", "image": 'assets/gas1.1.jpg'}],
    "Pediatrician": [{"title": "Child health issues", "image": 'assets/ped1.1.jpg'}],
    "ENT Specialist": [{"title": "Sore Throat", "image": 'assets/ent1.1.jpg'}],
    "Urologist": [{"title": "kidney stones", "image": 'assets/uro1.1.jpg'}],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchSpecialities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              final specialities = snapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 10),
                    const TopSection(),
                    // const SizedBox(height: 10),
                    const Text(
                      "25+ Specialities",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(height: 5),
                    const Text(
                      "Consult with top doctors across specialities",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    // const SizedBox(height: 10),
                    specialities.isEmpty
                        ? const Center(child: Text("No specialities available"))
                        : Stack(
                      children: [
                        SizedBox(
                            height: 410,
                            child:ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: specialities.length,
                              itemBuilder: (context, index) => _hasShownHint
                                  ? _buildSpecialityCard(context, specialities[index])
                                  : SlideTransition(
                                position: _slideAnimation,
                                child: _buildSpecialityCard(context, specialities[index]),
                              ),
                            )

                        ),
                        // Overlay hint text
                        if (!_hasShownHint)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.8, end: 1.0),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.touch_app_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Scroll horizontally',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(milliseconds: 600),
                                            tween: Tween(begin: 0, end: 1),
                                            curve: Curves.easeInOut,
                                            builder: (context, value, child) {
                                              return Transform.translate(
                                                offset: Offset(10 * value, 0),
                                                child: Opacity(
                                                  opacity: 0.6 + (0.4 * value),
                                                  child: const Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),

                    // const SizedBox(height: 10),
                    const Text(
                      "Common Health Concerns",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(height: 5),
                    const Text(
                      "Consult a doctor online for any health issue",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    // const SizedBox(height: 10),

                    specialities.isEmpty
                        ? const Center(child: Text("No concerns available"))
                        : SizedBox(
                      height: 190,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _buildHealthConcerns(specialities),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSpecialityCard(BuildContext context, Map<String, dynamic> data) {
    Map<String, String> specialityImages = {
      "General Physician": 'assets/g1.jpg',
      " Gynecologist": 'assets/gy1.jpg',
      "Dermatologist": 'assets/d1.jpg',
      "Sexologist": 'assets/s1.jpg',
      "Psychiatrist": 'assets/psy1.jpg',
      "Gastroenterologist": 'assets/gas1.jpg',
      "Pediatrician": 'assets/ped1.jpg',
      "ENT Specialist": 'assets/ent1.jpg',
      "Urologist": 'assets/uro1.jpg',
      "Nutritionist/Dietitian": 'assets/nd1.jpg',
      "Orthopedist": 'assets/orth1.jpg',
      "Neurologist": 'assets/neuro1.jpg',
      "Cardiologist": 'assets/car1.jpg',
      "Diabetology": 'assets/diabet1.jpg',
      "Eye & Vision": 'assets/eye1.jpg',
      "Dentist": 'assets/dentist1.jpg',
      "Pulmonologist": 'assets/pulmo1.jpg',
      "Homeopathy": 'assets/homeo1.jpg',
      "Ayurveda": 'assets/ayur1.jpg',
      "Cancer": 'assets/cancer1.jpg',
      "Rheumatology": 'assets/rheum1.jpg.jpg',
      "Physiotherapist": 'assets/physio1.jpg',
      "Veterinary": 'assets/verer1.jpg',
      "Nephrologist": 'assets/nephr1.jpg',
      "Trichologist": 'assets/trich1.jpg',

    };

    String specialityImage = specialityImages[data['speciality_name']] ?? 'assets/doctor.png';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpLoginScreen(
              speciality: data['speciality_name'],
              price: data['consultation_fee'].toString(),
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF5856D6), width: 2.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
              child: Image.asset(
                specialityImage,
                height: 290,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const Divider(color: Color(0xFF5856D6), thickness: 2.5, height: 0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8,),
                Text(
                  data['speciality_name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "₹${data['consultation_fee']}",
                  style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpLoginScreen(
                          speciality: data['speciality_name'],
                          price: data['consultation_fee'].toString(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    "Consult Now",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHealthConcerns(List<Map<String, dynamic>> specialities) {
    List<Widget> concernWidgets = [];
    for (var speciality in specialities) {
      if (concerns.containsKey(speciality['speciality_name'])) {
        for (var concern in concerns[speciality['speciality_name']]!) {
          concernWidgets.add(_buildHealthConcern(concern, speciality['speciality_name'], speciality['consultation_fee'].toString()));
        }
      }
    }
    return concernWidgets;
  }

  Widget _buildHealthConcern(Map<String, dynamic> data, String specialityName, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpLoginScreen(
              speciality: specialityName,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Image.asset(
                data['image']!,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 200,
              child: Text(
                data['title']!,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "₹$price",
              style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

