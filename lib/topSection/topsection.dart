import 'package:flutter/material.dart';

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isSmallScreen = screenWidth < 400; // Adjust for smaller screens

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns properly
            children: [
              // Left Section - Icons with Text (Wrap for Small Screens)
              Expanded(

                child: Wrap(
                  spacing: isSmallScreen ? 6 : 10, // Adjust spacing
                  runSpacing: 6, // Prevent overflow on smaller screens
                  children: [
                    _buildIconText(Icons.verified, "Verified Doctors", Colors.blue, isSmallScreen),
                    _buildIconText(Icons.receipt, "Digital Prescription", Colors.red, isSmallScreen),
                    _buildIconText(Icons.loop, "Free Follow-up", Colors.orange, isSmallScreen),
                  ],
                ),
              ),

              // Right Section - Logo (Scales for Different Screens)
              Image.asset(
                "assets/btclogo.png", // Replace with your logo asset
                height: isSmallScreen ? 60 : 80, // Scales based on screen size
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }

  // Responsive Widget for Icon and Text
  Widget _buildIconText(IconData icon, String text, Color color, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Prevents unnecessary expansion
      children: [
        Icon(icon, size: isSmallScreen ? 17 : 19, color: color),
        SizedBox(width: isSmallScreen ? 4 : 8),
        Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 15, // Adjusts text size
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
