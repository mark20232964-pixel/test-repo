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
        _buildField("Vehicle Model", _modelController, "e.g. Civic"),
const SizedBox(height: 24),
_buildField("Number Plate", _plateController, "e.g. KS 5241"),
const SizedBox(height: 24),
_buildField("Color", _colorController, "e.g. Red"),
const SizedBox(height: 48),
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () {
      // TODO: Implement save logic in next commit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verify button tapped - coming soon')),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1B1B4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: const Text(
      "Verify",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
const SizedBox(height: 20),
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