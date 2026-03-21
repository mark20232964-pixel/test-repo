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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Charges')),
      body: const Center(child: Text('UI Coming Soon')),
    );
  }
}