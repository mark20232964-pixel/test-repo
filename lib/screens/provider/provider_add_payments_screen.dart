// lib/screens/provider/add_charges_screen.dart

import 'package:flutter/material.dart';

class AddChargesScreen extends StatefulWidget {
  final String customerName;
  final String serviceName;   // e.g. "Tyre Change" or "Headlight Change"

  const AddChargesScreen({
    super.key,
    required this.customerName,
    required this.serviceName,
  });

  @override
  State<AddChargesScreen> createState() => _AddChargesScreenState();
}

class _AddChargesScreenState extends State<AddChargesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Add Charges'),
          backgroundColor: const Color(0xFF1B1B4B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('Form coming soon')),
    );
  }
}