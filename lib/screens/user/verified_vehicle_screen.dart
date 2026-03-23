import 'package:flutter/material.dart';

class VerifiedVehicleScreen extends StatelessWidget {
  const VerifiedVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Verified Vehicle"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Verified Vehicle Screen - Step 1', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}