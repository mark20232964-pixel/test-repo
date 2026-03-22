import 'package:flutter/material.dart';

class VehicleVerificationFormScreen extends StatefulWidget {
  final String brandName;
  final String logoUrl;

  const VehicleVerificationFormScreen({
    super.key,
    required this.brandName,
    required this.logoUrl,
  });

  @override
  State<VehicleVerificationFormScreen> createState() => _VehicleVerificationFormScreenState();
}

class _VehicleVerificationFormScreenState extends State<VehicleVerificationFormScreen> {
   final _modelController = TextEditingController(text: "Civic");
  final _plateController = TextEditingController(text: "KS 5241");
  final _colorController = TextEditingController(text: "Red");

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Get Verified",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
        body: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.network(
            widget.logoUrl,
            height: 80,
            width: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.car_repair, size: 80),
          ),
        ),
        const SizedBox(height: 32),
        // Form fields will be added in next commits
        const Text('Form fields coming soon', style: TextStyle(fontSize: 20)),
      ],
    ),
  ),
    );
  }
}
Widget _buildField(String label, TextEditingController controller, String hint) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: const UnderlineInputBorder(),
        ),
      ),
    ],
  );
}