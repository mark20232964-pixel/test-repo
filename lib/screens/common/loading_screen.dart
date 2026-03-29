import 'dart:async';
import 'package:flutter/material.dart';

import '../user/user_dashboard.dart';
import '../provider/provider_dashboard.dart';

class LoadingScreen extends StatefulWidget {
  final String role;

  const LoadingScreen({super.key, required this.role});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // simulate loading (2.5 seconds)
    Timer(const Duration(seconds: 2), () {
      if (widget.role == 'provider') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderDashboard(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UserDashboard(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1464),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 LOGO
            ClipOval(
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 40),

            // 🔥 LOADING BAR
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                minHeight: 5,
                color: Colors.orange,
                backgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
