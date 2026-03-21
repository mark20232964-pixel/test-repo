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
  final _customServiceController = TextEditingController(); 
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
    };

    final trimmed = widget.serviceName.trim();
    _selectedService = validServices.contains(trimmed) ? trimmed : null;

    // Warn if pre-filled value didn't match
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
    _customServiceController.dispose();
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
    FocusScope.of(context).unfocus();

    // TODO: Save to Firebase / backend here
    await Future.delayed(const Duration(seconds: 1)); // fake delay

    setState(() => _isLoading = false);

    if (!mounted) return;

    final displayService = _selectedService == 'Other'
        ? _customServiceController.text.trim()
        : _selectedService;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Charges'),
        backgroundColor: const Color(0xFF1B1B4B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with customer and mechanic info
                Text(
                  widget.customerName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mechanic: ${widget.mechanicName}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 32),

                // Provided Service
                const Text(
                  'Provided Service',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedService,
                  isExpanded: true,
                  hint: const Text('Choose Service', style: TextStyle(color: Colors.black54)),
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
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                      // Optional: clear custom field when switching away from Other
                      if (value != 'Other') _customServiceController.clear();
                    });
                  },
                  validator: (value) => value == null ? 'Please select a service' : null,
                ),

                // Custom service field – only visible when "Other" is selected
                if (isOtherSelected) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Custom Service Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _customServiceController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'e.g. Oil Change, AC Repair',
                      hintStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) {
                      if (isOtherSelected && (value == null || value.trim().isEmpty)) {
                        return 'Please enter the custom service name';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Price
                const Text(
                  'Price (LKR)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Insert Price',
                    hintStyle: const TextStyle(color: Colors.black54),
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

              ],
            ),
          ),
        ),
      ),
    );
  }
}