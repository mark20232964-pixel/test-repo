// lib/screens/provider/add_charges_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddChargesScreen extends StatefulWidget {
  final String customerName;
  final String serviceName;
  final String mechanicName;
  final String? requestId;

  const AddChargesScreen({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.mechanicName,
    this.requestId,
  });

  @override
  State<AddChargesScreen> createState() => _AddChargesScreenState();
}

class _AddChargesScreenState extends State<AddChargesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedService;
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Safe pre-fill: only set if it matches one of the allowed values
    const validServices = {
      'Tire Change',
      'Battery Replacement',
      'Headlight Change',
      'Towing',
      'Fuel Delivery',
      'Jump Start',
      'Emergency Repair',
      'Other',
      // Add more services here when you know them (e.g. 'Oil Change')
    };

    final trimmed = widget.serviceName.trim();
    _selectedService = validServices.contains(trimmed) ? trimmed : null;

    // Optional: warn user if pre-fill failed
    if (_selectedService == null && trimmed.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service "$trimmed" not found – please select manually')),
        );
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitCharges() async {
    if (!_formKey.currentState!.validate()) return;

    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid positive price')),
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // hide keyboard

    // TODO: Save to Firebase / backend here
    await Future.delayed(const Duration(seconds: 1)); // fake delay

    setState(() => _isLoading = false);

    if (!mounted) return;

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
            const Text('Success!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
              'LKR $price added for ${widget.customerName}\nService: $_selectedService',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with overflow protection
                Text(
                  widget.customerName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mechanic: ${widget.mechanicName}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 32),

                const Text('Provided Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedService,
                  isExpanded: true,
                  hint: const Text('Choose Service'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Tire Change', child: Text('Tire Change')),
                    DropdownMenuItem(value: 'Battery Replacement', child: Text('Battery Replacement')),
                    DropdownMenuItem(value: 'Headlight Change', child: Text('Headlight Change')),
                    DropdownMenuItem(value: 'Towing', child: Text('Towing')),
                    DropdownMenuItem(value: 'Fuel Delivery', child: Text('Fuel Delivery')),
                    DropdownMenuItem(value: 'Jump Start', child: Text('Jump Start')),
                    DropdownMenuItem(value: 'Emergency Repair', child: Text('Emergency Repair')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) => setState(() => _selectedService = value),
                  validator: (value) => value == null ? 'Please select a service' : null,
                ),
                const SizedBox(height: 24),

                const Text('Price (LKR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Insert Price',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter price';
                    final num = double.tryParse(value.trim());
                    if (num == null || num <= 0) return 'Enter valid positive amount';
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitCharges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A48FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: _isLoading ? 0 : 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}