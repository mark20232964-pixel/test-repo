import 'package:flutter/material.dart';
import 'package:roadresq/screens/common/role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Bottom part is solid black
      body: Column(
        children: [
          // 1. Top Image Part (Takes up roughly 55-60% of the screen)
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/welcome_hero.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // The specific white/grey gradient fade at the bottom of the image
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Bottom Content Part (Solid Black background)
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Stranded? We\nBring the Help to\nYou!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to your roadside rescue corner,\nwhere every journey becomes safe again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),

                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const RoleSelectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0D0B4A), // Exact Navy from pic
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Language Pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _langPill("ENGLISH", true),
                      const SizedBox(width: 10),
                      _langPill(
                          "தமிழ்", true), // Middle one is also dark in your pic
                      const SizedBox(width: 10),
                      const Text("සිංහල",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _langPill(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0B4A) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
