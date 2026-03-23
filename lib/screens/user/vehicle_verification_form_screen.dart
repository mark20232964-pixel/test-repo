// vehicle_verification_form_screen.dart
// Screen for entering vehicle details after selecting brand
// Features: form fields with validation, icons, focus navigation,
// loading spinner, Firestore save, success confetti, auto-clear
// Navigation: from verify_vehicle_screen on brand tap → here
// Next: brand details confirmation, image upload for proof
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile_screen.dart'; 
import 'package:flutter/services.dart';  

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

  

  bool _isLoading = false;

    final _modelFocus = FocusNode();
  final _plateFocus = FocusNode();
  final _colorFocus = FocusNode();

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final user = FirebaseAuth.instance.currentUser;

    if (_modelController.text.trim().isEmpty ||
        _plateController.text.trim().isEmpty ||
        _colorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final vehicleData = {
      "brand": widget.brandName,
      "model": _modelController.text.trim(),
      "plate": _plateController.text.trim(),
      "color": _colorController.text.trim(),
      "userId": user?.uid,
      "createdAt": Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection("vehicles").add(vehicleData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vehicle Verified & Saved! ✅")),
    );

    // Clear fields
    _modelController.clear();
    _plateController.clear();
    _colorController.clear();

    // Small delay to show success message
    await Future.delayed(const Duration(seconds: 1));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserProfileScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving vehicle: $e")),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
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
          const Text(
    'Enter Vehicle Details',
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
  ),
  const SizedBox(height: 24),
  Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildField(
            "Vehicle Model",
            _modelController,
            "e.g. Civic",
            Icons.directions_car,
            focusNode: _modelFocus,
            nextFocus: _plateFocus,
          ),
          const SizedBox(height: 16),
          _buildField(
            "Number Plate",
            _plateController,
            "e.g. KS 5241",
            Icons.numbers,
            focusNode: _plateFocus,
            nextFocus: _colorFocus,
          ),
          const SizedBox(height: 16),
          _buildField(
            "Color",
            _colorController,
            "e.g. Red",
            Icons.palette,
            focusNode: _colorFocus,
            nextFocus: null, // last field
          ),
        ],
      ),
    ),
  ),
  const SizedBox(height: 48),
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: _isLoading || _modelController.text.trim().isEmpty || _plateController.text.trim().isEmpty || _colorController.text.trim().isEmpty
    ? null
    : _saveVehicle,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1B1B4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: _isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text(
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

Widget _buildField(String label, TextEditingController controller, String hint, IconData icon,{FocusNode? focusNode,     // ← ADDED this
   FocusNode? nextFocus}) {
  final isEmpty = controller.text.trim().isEmpty && _isLoading;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isEmpty ? Colors.red : Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
TextField(
  controller: controller,
  focusNode: focusNode,
  textInputAction: TextInputAction.next,
  keyboardType: TextInputType.text,
  textCapitalization: TextCapitalization.words,
  // CHANGED: removed UpperCaseTextFormatter — no auto-uppercase anymore
  inputFormatters: label == "Number Plate"
      ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]'))]  // only allow uppercase letters, numbers, spaces
      : null,
  decoration: InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    prefixIcon: Icon(icon, color: Colors.grey),
    filled: true,
    fillColor: controller.text.isNotEmpty ? Colors.grey[50] : null,
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF6A48FF), width: 2),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: isEmpty ? Colors.red : Colors.grey),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    errorText: isEmpty ? 'This field is required' : null,
    errorStyle: const TextStyle(color: Colors.red),
  ),
  onChanged: (value) {
    setState(() {}); // Update fill color + clear red
  },
),
      const SizedBox(height: 16),
    ],
  );
}

}
