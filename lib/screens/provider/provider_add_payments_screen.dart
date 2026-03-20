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

  String? _selectedService;
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedService = widget.serviceName; // Pre-fill from the request
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submitCharges() {
    final priceText = _priceController.text.trim();

    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the price')),
      );
      return;
    }

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    // For now: fake success (later: save to Firebase)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6F4E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Charges added for ${widget.customerName}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Adding charges for\n${widget.customerName}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Provided Service Dropdown
              const Text(
                'Provided Service',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedService,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Tire Change', child: Text('Tire Change')),
                  DropdownMenuItem(
                    value: 'Battery Replacement',
                    child: Text('Battery Replacement')),
                  DropdownMenuItem(value: 'Headlight Change', child: Text('Headlight Change')),
                  DropdownMenuItem(value: 'Towing', child: Text('Towing')),
                  DropdownMenuItem(value: 'Fuel Delivery', child: Text('Fuel Delivery')),
                  DropdownMenuItem(value: 'Jump Start', child: Text('Jump Start')),
                  DropdownMenuItem(
                    value: 'Emergency Repair', child: Text('Emergency Repair')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
              ),  

              const SizedBox(height: 24),

              // Price Field
              const Text(
                'Price (LKR)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Insert Price',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),

            const SizedBox(height: 48),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitCharges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A48FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
    );
  }
}