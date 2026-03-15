import 'package:flutter/material.dart';

class VerifyVehicleScreen extends StatelessWidget {
  const VerifyVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Text('Verify Vehicle Screen - Step 1', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}