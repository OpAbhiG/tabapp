import 'package:flutter/material.dart';
import '../APIServices/base_api.dart';
import '../signin_signup/otp_login.dart';
import '../topSection/topsection.dart';




// class SlidableSpecialistsScreen extends StatefulWidget {
//   const SlidableSpecialistsScreen({super.key});
//
//   @override
//   State<SlidableSpecialistsScreen> createState() => _SlidableSpecialistsScreenState();
// }
//
// class _SlidableSpecialistsScreenState extends State<SlidableSpecialistsScreen> {
//   final List<Map<String, dynamic>> specialists = [
//     {"title": "Cardiologist", "price": "₹199/-", "image": "assets/phy.png"},
//     {"title": "Oncologist", "price": "₹199/-", "image": "assets/doctor/d1.jpg"},
//     {"title": "Pediatrician", "price": "₹199/-", "image": "assets/doctor/d2.jpg"},
//     {"title": "Cardiothoracic Surgeon", "price": "₹199/-", "image": "assets/doctor/d3.jpg"},
//     {"title": "Gynecologist", "price": "₹199/-", "image": "assets/doctor/d4.jpg"},
//     {"title": "PHARMACIST", "price": "Free!", "image": "assets/doctor/d5.jpg"},
//   ];
//
//   final List<Map<String, String>> concerns = [
//     {"image": "assets/consern/cough.jpg", "title": "Cough & Cold?", "price": "₹199"},
//     {"image": "assets/consern/period.jpg", "title": "Period problems?", "price": "₹199"},
//     {"image": "assets/consern/performance.jpg", "title": "Performance issues in bed?", "price": "₹199"},
//     {"image": "assets/consern/skin.jpg", "title": "Skin problems?", "price": "₹199"},
//     {"image": "assets/consern/skin.jpg", "title": "Depression or Anxiety?", "price": "₹199"},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//        child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//         child: SingleChildScrollView(
//           child:Column(
//           children: [
//
//             const SizedBox(height: 15,),
//             TopSection(), // This adds the top header
//
//             const SizedBox(height: 10),
//             // Centered Slidable Cards (Specialists)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
//                   children: [
//                     Text(
//                       "25+ Specialists",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8), // Adds spacing between the texts
//                     Text(
//                       "Consult with top doctors across Specialists",
//                       style: TextStyle(fontSize: 12,color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 230,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: specialists.length,
//                 itemBuilder: (context, index) {
//                   final specialist = specialists[index];
//                   return Container(
//                     width: 150,
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(specialist['image'], height: 60, fit: BoxFit.cover),
//                             const SizedBox(height: 8),
//                             Text(
//                               specialist['title'],
//                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.center,
//                             ),
//                             Text(
//                               specialist['price'],
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                             const SizedBox(height: 8),
//                             ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) =>  OtpLoginScreen(
//                                     speciality: specialist['title'], // Pass the selected specialist title
//                                     price: specialist['price'], // Pass the selected price
//                                   )),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(80, 30)),
//                               child: const Text("Consult Now",style: TextStyle(color: Colors.white,fontSize: 10),),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             ////second slide////
//
//             const SizedBox(height: 20),
//             // Second Slidable Cards (Doctors)
//             const Padding(
//               padding: EdgeInsets.all(10.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
//                   children: [
//                     Text(
//                       "Common Health Concerns",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8), // Adds spacing between the texts
//                     Text(
//                       "Cosult a doctor online for any health issue",
//                       style: TextStyle(fontSize: 12,color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 190, // Adjust height
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: concerns.length,
//                 itemBuilder: (context, index) {
//                   final concern = concerns[index];
//                   return Container(
//                     width: 130, // Adjust card width
//                     margin: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           // Image Section
//                           ClipRRect(
//                             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                             child: Image.asset(
//                               concern['image']!,
//                               height: 80, // Adjust image size
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   concern['title']!,
//                                   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   concern['price']!,
//                                   style: const TextStyle(fontSize: 12, color: Colors.red),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(builder: (context) => OtpLoginScreen(
//                                         speciality: concern['title'] ?? "Unknown", // Default value
//                                         price: concern['price'] ?? "₹0", // Default price
//
//                                       )),
//                                     );
//                                   },
//                                   child: const Row(
//                                     mainAxisSize: MainAxisSize.min, // Prevents extra spacing
//                                     children: [
//                                       Text(
//                                         "Consult Now",
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.blue, // Blue color like a hyperlink
//                                           decoration: TextDecoration.underline, // Adds underline
//                                         ),
//                                       ),
//                                       SizedBox(width: 4), // Space between text and icon
//                                       Icon(Icons.arrow_forward_ios, size: 10, color: Colors.blue), // Small arrow icon
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),),
//       ))
//
//
//     );
//   }
// }
//

import 'dart:convert';
import 'package:http/http.dart' as http;



// v1
// class SpecialitiesScreen extends StatefulWidget {
//   const SpecialitiesScreen({super.key});
//
//   @override
//   State<SpecialitiesScreen> createState() => _SpecialitiesScreenState();
// }
//
// class _SpecialitiesScreenState extends State<SpecialitiesScreen> {
//
//   List<Map<String, dynamic>> specialities = [
//
//   ];
//   Map<String, List<Map<String, dynamic>>> concerns = {};
//
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSpecialities();
//   }
//
//   Future<void> fetchSpecialities() async {
//     final response = await http.get(Uri.parse("$baseapi/tab/tb-speciality"));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print(response.body);
//       setState(() {
//         specialities = List<Map<String, dynamic>>.from(data["specialities"]);
//         mapConcerns();
//       });
//     } else {
//       print("Failed to load specialities");
//     }
//   }
//
//
//
//
//   void mapConcerns() {
//     concerns = {
//       "General Physician": [{"title": "Cough & Cold", "image": 'assets/consern/cough.jpg'}],
//       // "Cardiologist": [{"title": "Chest Pain", "image": 'assets/consern/chest_pain.jpg'}],
//       "Dermatologist": [{"title": "Skin Problem", "image": 'assets/consern/skin.jpg'}],
//       // "Orthopedic Surgeon": [{"title": "Joint Pain", "image": 'assets/consern/joint_pain.jpg'}],
//       // "Neurologist": [{"title": "Migraines", "image": 'assets/consern/migraine.jpg'}],
//       "Pediatrician": [{"title": "Child Health", "image": 'assets/sickkid.jpg'}],
//       // "Psychiatrist": [{"title": "Mental Health", "image": 'assets/consern/mental_health.jpg'}],
//       // "Ophthalmologist": [{"title": "Eye Checkup", "image": 'assets/consern/eye_checkup.jpg'}],
//       // "ENT Specialist": [{"title": "Ear Pain", "image": 'assets/consern/ear_pain.jpg'}],
//       // "Dentist": [{"title": "Toothache", "image": 'assets/consern/toothache.jpg'}],
//       "Neurologist": [{"title": "Performance Issue", "image": 'assets/consern/performance.jpg'}],
//       "Gynecologist": [{"title": "Period Problem", "image": 'assets/consern/Period.jpg'}],
//
//
//
//     };    // Ensure all API specialities have a default concern
//     // for (var speciality in specialities) {
//     //   String specialityName = speciality['speciality_name'];
//     //   if (!concerns.containsKey(specialityName)) {
//     //     concerns[specialityName] = [
//     //       {
//     //         "title": "General Consultation",
//     //         "image": 'assets/general.jpg'
//     //       }
//     //     ];
//     //   }
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 10),
//                 const TopSection(),
//
//                 const SizedBox(height: 10),
//                 const Text(
//                   "25+ Specialities",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   "Consult with top doctors across specialities",
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 20),
//                 specialities.isEmpty
//                     ? const Center(child: CircularProgressIndicator())
//                     : SizedBox(
//                   height: 310,
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     children: specialities.asMap().entries.map((entry) {
//                       int index = entry.key;
//                       Map<String, dynamic> data = entry.value;
//                       return _buildSpecialityCard(data, index);
//                     }).toList(),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Common Health Concerns",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   "Consult a doctor online for any health issue",
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 10),
//                 specialities.isEmpty
//                     ? const Center(child: CircularProgressIndicator())
//                     : SizedBox(
//                   height: 130,
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     children: _buildHealthConcerns(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSpecialityCard(Map<String, dynamic> data, int index) {
//     // Map speciality names to specific images
//     Map<String, String> specialityImages = {
//       "General Physician": 'assets/general.jpg',
//       "Cardiologist": 'assets/doctor/d2.jpg',
//       "Dermatologist": 'assets/dermatology.jpg',
//       "Neurologist": 'assets/doctor/d4.jpg',
//       "Pediatrician": 'assets/doctor/d5.jpg',
//       "Orthopedic": 'assets/doctor/d5.jpg',
//       "Psychiatrist":'assets/psychiatry.jpg',
//
//     };
//
//     // Default image if speciality not found
//     String specialityImage = specialityImages[data['speciality_name']] ?? 'assets/s4.jpg';
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OtpLoginScreen(
//               speciality: data['speciality_name'],
//               price: data['consultation_fee'].toString(),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: 165,
//         margin: const EdgeInsets.only(right: 15),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.blue, width: 1),
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(25),
//                 topRight: Radius.circular(25),
//               ),
//               child: Image.asset(
//                 specialityImage, // Fixed image based on speciality
//                 height: 165,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const Divider(color: Colors.blue, thickness: 1, height: 0),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     data['speciality_name'],
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   Text(
//                     "₹${data['consultation_fee']}",
//                     style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => OtpLoginScreen(
//                             speciality: data['speciality_name'],
//                             price: data['consultation_fee'].toString(),
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                     ),
//                     child: const Text(
//                       "Consult Now",
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildHealthConcerns() {
//     List<Widget> concernWidgets = [];
//     for (var speciality in specialities) {
//       if (concerns.containsKey(speciality['speciality_name'])) {
//         for (var concern in concerns[speciality['speciality_name']]!) {
//           concernWidgets.add(_buildHealthConcern(concern, speciality['speciality_name'], speciality['consultation_fee'].toString()));
//         }
//       }
//     }
//     return concernWidgets;
//   }
//
//   Widget _buildHealthConcern(Map<String, dynamic> data, String specialityName, String price) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OtpLoginScreen(
//               speciality: specialityName,
//               price: price,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: 110,
//         margin: const EdgeInsets.only(right: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               child: Image.asset(
//                 data['image']!,
//                 height: 75,
//                 width: 95,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             // const SizedBox(height: 5),
//             SizedBox(
//               width: 120,
//               child: Text(
//                 data['title']!,
//                 textAlign: TextAlign.left,
//                 style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             // const SizedBox(height: 4),
//             Text(
//               "₹$price",
//               style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }


//v2
class SpecialitiesScreen extends StatefulWidget {
   SpecialitiesScreen({super.key});

  @override
  State<SpecialitiesScreen> createState() => _SpecialitiesScreenState();
}

class _SpecialitiesScreenState extends State<SpecialitiesScreen> {

  Future<List<Map<String, dynamic>>> fetchSpecialities() async {
    final response = await http.get(Uri.parse("$baseapi/tab/tb-speciality"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(response.body);
      return List<Map<String, dynamic>>.from(data["specialities"]);
    } else {
      throw Exception("Failed to load specialities");
    }
  }

  final Map<String, List<Map<String, dynamic>>> concerns = {
    "General Physician": [{"title": "Cough & Cold", "image": 'assets/doctor.png'}],
    "Dermatologist": [{"title": "Skin Problem", "image": 'assets/img.png'}],
    "Pediatrician": [{"title": "Child Health", "image": 'assets/phy.png'}],
    "Neurologist": [{"title": "Performance Issue", "image": 'assets/s1.jpg'}],
    "Gynecologist": [{"title": "Period Problem", "image": 'assets/s2.jpg'}],
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const TopSection(),
                    const SizedBox(height: 10),
                    const Text(
                      "25+ Specialities",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Consult with top doctors across specialities",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    specialities.isEmpty
                        ? const Center(child: Text("No specialities available"))
                        : SizedBox(
                      height: 310,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: specialities.map((data) => _buildSpecialityCard(context, data)).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Common Health Concerns",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Consult a doctor online for any health issue",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    specialities.isEmpty
                        ? const Center(child: Text("No concerns available"))
                        : SizedBox(
                      height: 130,
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
      "General Physician": 'assets/doctor/d3.jpg',
      "Cardiologist": 'assets/doctor/d1.jpg',
      "Dermatologist": 'assets/doctor/d3.jpg',
      "Neurologist": 'assets/doctor/d1.jpg',
      "Pediatrician": 'assets/doctor/d3.jpg',
      "Orthopedic": 'assets/doctor/d4.jpg',
      "Psychiatrist": 'assets/doctor/d1.jpg',
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
        width: 165,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: Image.asset(
                specialityImage,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const Divider(color: Colors.blue, thickness: 1, height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data['speciality_name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "₹${data['consultation_fee']}",
                    style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
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
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Image.asset(
                data['image']!,
                height: 75,
                width: 95,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                data['title']!,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "₹$price",
              style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

