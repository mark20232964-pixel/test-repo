import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddChargesScreen extends StatefulWidget {
  final String customerName;
  final String serviceName;
  final String mechanicName;
  final String requestId;

  const AddChargesScreen({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.mechanicName,
    required this.requestId,
  });

  @override
  State<AddChargesScreen> createState() => _AddChargesScreenState();
}

class _AddChargesScreenState extends State<AddChargesScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedService;
  final _priceController = TextEditingController();
  final _customServiceController = TextEditingController();

  bool _isLoading = false;

  // Full valid list
  final List<String> _services = [
    "Tire Change",
    "Battery Replacement",
    "Headlight Change",
    "Towing",
    "Fuel Delivery",
    "Jump Start",
    "Emergency Repair",
    "Other",
  ];

  @override
  void initState() {
    super.initState();

    final incoming = widget.serviceName.trim();

    // FIX: Prevent dropdown crash
    if (_services.contains(incoming)) {
      _selectedService = incoming;
    } else if (incoming.isNotEmpty) {
      _selectedService = "Other";
      _customServiceController.text = incoming;
    } else {
      _selectedService = null;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _customServiceController.dispose();
    super.dispose();
  }

  Future<void> _submitCharges() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final serviceName = _selectedService == "Other"
          ? _customServiceController.text.trim()
          : _selectedService;

      if (serviceName == null || serviceName.isEmpty) {
        throw Exception("Service required");
      }

      // UPDATE FIRESTORE (WebXPay ready)
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'amount': price,
        'serviceType': serviceName,
        'status': 'completed',

        // PAYMENT SYSTEM
        'paidStatus': 'pending',
        'paymentMethod': null,
        'paymentId': null,
        'paidAt': null,

        'completedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // SUCCESS UI
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 15),
              const Text(
                "Success!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "LKR ${price.toStringAsFixed(0)} added successfully",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOther = _selectedService == "Other";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Charges"),
        backgroundColor: const Color(0xFF120A4D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info
              Text(
                widget.customerName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Mechanic: ${widget.mechanicName}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Service Dropdown
              const Text("Service"),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedService,
                hint: const Text("Select Service"),
                items: _services
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedService = val;
                    if (val != "Other") {
                      _customServiceController.clear();
                    }
                  });
                },
                validator: (val) =>
                    val == null ? "Please select service" : null,
              ),

              // Custom Service
              if (isOther) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customServiceController,
                  decoration: const InputDecoration(
                    labelText: "Custom Service",
                  ),
                  validator: (val) {
                    if (isOther && (val == null || val.trim().isEmpty)) {
                      return "Enter custom service";
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 25),

              // Price
              const Text("Price (LKR)"),
              const SizedBox(height: 8),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: "Enter amount",
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Enter price";
                  }
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) {
                    return "Invalid amount";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCharges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF120A4D),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SUBMIT",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}