// lib/screens/provider/provider_dashboard.dart

import 'package:flutter/material.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Provider Dashboard - Step 1',
          style: TextStyle(fontSize: 28, color: Colors.black),
        ),
      ),
    );
  }
}
