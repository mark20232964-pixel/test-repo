import 'package:flutter/material.dart';

class AddGarageScreen extends StatefulWidget {
  const AddGarageScreen({super.key});

  @override
  State<AddGarageScreen> createState() => _AddGarageScreenState();
}

class _AddGarageScreenState extends State<AddGarageScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  final Map<String, bool> _serviceCategories = {
    'Towing': true,
    'Battery Replacement': false,
    'Tire Change': false,
    'Fuel Delivery': false,
    'Jump Start': true,
    'Emergency Repair': true,
    'Other': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitGarage() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedServices = _serviceCategories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ── TODO: Replace with real API / Firebase call ────────────────
    await Future.delayed(const Duration(seconds: 2)); // fake delay

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
            const Text(
              'Success!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text(
              'Garage Added. Thank You!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // dialog
                  Navigator.pop(context); // screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Add a Garage'),
        backgroundColor: const Color(0xFF1B1B4B),
        surfaceTintColor: Colors.transparent,
        // foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12), 
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Garage Name
                const Text('Garage Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  cursorColor: const Color(0xFF6A48FF),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                  decoration: _inputDecoration('e.g. ABC Motors'),
                ),
                const SizedBox(height: 16),

                // Address
                const Text('Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  cursorColor: const Color(0xFF6A48FF),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                  decoration: _inputDecoration('e.g. 123, Main St, Colombo'),
                ),
                const SizedBox(height: 16),

                // Contact Number
                const Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  cursorColor: const Color(0xFF6A48FF),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.length < 9) return 'Too short';
                    return null;
                  },
                  decoration: _inputDecoration('e.g. 0778404504'),
                ),
                const SizedBox(height: 16),

                // Email
                const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  cursorColor: const Color(0xFF6A48FF),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null; // optional
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                  decoration: _inputDecoration('e.g. abc@gmail.com'),
                ),
                const SizedBox(height: 16),

                // Description
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  cursorColor: const Color(0xFF6A48FF),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  minLines: 2,
                  maxLines: 2,
                  decoration: _inputDecoration('e.g. Full-service auto repair shop'),
                ),
                const SizedBox(height: 20),

                // Service Categories
                const Text('Service Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 8),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossCount = constraints.maxWidth > 500 ? 3 : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossCount,
                      childAspectRatio: 3.8,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 8,
                      children: _serviceCategories.keys.map((service) {
                        return CheckboxListTile(
                          title: Text(service, style: const TextStyle(fontSize: 15)),
                          value: _serviceCategories[service]!,
                          dense: true,
                          activeColor: const Color(0xFF6A48FF),
                          onChanged: (bool? value) {
                            setState(() {
                              _serviceCategories[service] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitGarage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A48FF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}