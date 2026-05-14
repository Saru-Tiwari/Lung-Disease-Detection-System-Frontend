import 'package:flutter/material.dart';
import 'package:personal_health_assistant/homepage/onboarding.dart'; // <-- import your onboarding page

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
      home: const HealthAssistantPage(), // <-- launch onboarding here
    );
  }
}
