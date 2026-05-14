import 'package:flutter/material.dart';
import 'package:personal_health_assistant/homepage/login.dart';

void main() {
  runApp(const HealthAssistantApp());
}

class HealthAssistantApp extends StatelessWidget {
  const HealthAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HealthAssistantPage(),
    );
  }
}

class HealthAssistantPage extends StatefulWidget {
  const HealthAssistantPage({super.key});

  @override
  State<HealthAssistantPage> createState() => _HealthAssistantPageState();
}

class _HealthAssistantPageState extends State<HealthAssistantPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              // Background image (top part)
              SizedBox(
                height: screenHeight * 0.4,
                width: screenWidth,
                child: Image.asset('assets/Onboard.jpeg', fit: BoxFit.cover),
              ),

              // White card covering the bottom part
              Positioned(
                top: screenHeight * 0.33, // overlap nicely
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Lungs Health',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Text(
                          'Assistant',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome to your journey towards better health. We\'re here to help you track your lungs health, understand your body, and achieve your wellness goals.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Permission items
                        _buildPermissionItem(
                          icon: Icons.check_circle_outline,
                          text:
                              'Allow access to respiratory health data to analyze lung condition and identify potential abnormalities early.',
                          color: const Color(0xFFCC6699),
                        ),
                        const SizedBox(height: 16),

                        _buildPermissionItem(
                          icon: Icons.check_circle_outline,
                          text:
                              'Upload and analyze chest images and health information to receive AI-based insights on lung health.',
                          color: const Color(0xFFCC6699),
                        ),
                        const SizedBox(height: 16),

                        _buildPermissionItem(
                          icon: Icons.info_outline,
                          text:
                              'Your lung health data is private and secure. All information is processed safely and never shared without your consent.',
                          color: const Color(0xFFCC6699),
                          isBold: true,
                        ),

                        const SizedBox(height: 36),

                        // Button
                        Center(
                          child: SizedBox(
                            width: screenWidth * 0.7, // responsive width
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE655A8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String text,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF666666),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
