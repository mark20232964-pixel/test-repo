// lib/screens/common/auth_screen.dart
// Handles login/signup for a given role (provider or driver)

import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  final String role;

  const AuthScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(role == 'provider' ? 'Service Provider' : 'Driver'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login / Sign Up for ${role == 'provider' ? 'Provider' : 'Driver'}',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 40),

            // Fake email field
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 16),

            // Fake password field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 32),

            // Fake Login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login attempted – skip for now'),
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
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Temporary Skip button (we'll replace with real login later)
            ElevatedButton(
              onPressed: () {
                if (role == 'provider') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ProviderDashboardPlaceholder(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserDashboardPlaceholder(),
                    ),
                  );
                }
              },
              child: const Text('Skip Login - Go to Dashboard (Test Mode)'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderDashboardPlaceholder extends StatelessWidget {
  const ProviderDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Text(
          'Provider Dashboard - Coming Soon',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
    );
  }
}

class UserDashboardPlaceholder extends StatelessWidget {
  const UserDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Text(
          'User/Driver Dashboard - Coming Soon',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
    );
  }
}
