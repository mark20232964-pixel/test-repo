import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: const Center(
        child: Text(
          'Welcome Screen - Step 1',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
    );
  }
}
