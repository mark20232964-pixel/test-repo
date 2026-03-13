import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        // ← added for better edge handling on devices
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
          ), // ← side padding
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.end, // ← content pushed to bottom
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Stranded? We\nBring the Help to You!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.15, // ← better line spacing
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Welcome to your roadside rescue corner,\nwhere every journey becomes safe again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 80), // ← extra space below text for now

              const SizedBox(height: 40), // space before button

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Get Started clicked – next step coming soon!',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A48FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ), // space after button (for next elements later)
            ],
          ),
        ),
      ),
    );
  }
}
