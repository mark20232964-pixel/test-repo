// lib/screens/common/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔵 TOP HEADER
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0647),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        'assets/images/pattern.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(), // Fixes "Asset not found"
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 80,
                  left: 25,
                  child: Text(
                    "Select your role",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 25,
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    width: 75,
                    height: 75,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.shield, color: Colors.white, size: 50),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text("Sign up",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 5),
                  Container(
                      width: 45, height: 4, color: const Color(0xFFD48C6A)),
                  const SizedBox(height: 50),
                  _roleButton(context, "Service Provider", 'provider'),
                  const SizedBox(height: 20),
                  _roleButton(context, "Driver", 'driver'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleButton(BuildContext context, String label, String role) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A0647),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AuthScreen(role: role)));
        },
        child: Text(label,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
