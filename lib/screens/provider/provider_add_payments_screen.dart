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
            
            ],
          ),
        ),
    );
  }
}