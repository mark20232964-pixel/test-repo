import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _mechanicsController = TextEditingController(); // ← new field

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
    _mechanicsController.dispose();
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

    // TODO: Replace with real API / Firebase call
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Garage "${_nameController.text.trim()}" added!',
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
                  foregroundColor: Colors.black87,
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
        title: const Text('Add a Garage'),
        backgroundColor: const Color(0xFF1B1B4B),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Add Garage Name field
                const Text('Garage Name', style: TextStyle(fontSize:14,fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black87),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                  decoration: _inputDecoration('e.g. ABC Motors'),
                ),
                const SizedBox(height: 20),

                // Add Address field
                const Text('Address', style: TextStyle(fontSize:14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.black87),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                  decoration: _inputDecoration('e.g. 123, Main St, Colombo'),
                ),
                const SizedBox(height: 20),

                // Add Contact Number field 
                const Text('Contact Number', style: TextStyle(fontSize:14,fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black87),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.length < 9) return 'Too short';
                    return null;
                  },
                  decoration: _inputDecoration('e.g. 0778404504'),
                ),
                const SizedBox(height: 20),

                // Add Email field
                const Text('Email Address', style: TextStyle(fontSize:14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black87),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid email';
                    return null;
                  },
                  decoration: _inputDecoration('e.g. abc@gmail.com'),
                ),
                const SizedBox(height: 20),

                // Add Description field
                const Text('Description', style: TextStyle(fontSize:14,fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _inputDecoration('e.g. Full-service auto repair shop'),
                ),
                const SizedBox(height: 24),

                // Mechanics Available field
                const Text(
                  'Mechanics Available in Garage',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mechanicsController,
                  maxLines: 3,
                  minLines: 2,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'John Doe, Sarah Perera, Kasun Wickramasinghe\n(one per line or comma separated)',
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // Service Categories
                const Text(
                  'Service Categories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossCount = constraints.maxWidth > 500 ? 3 : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossCount,
                      childAspectRatio: 3.2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 8,
                      children: _serviceCategories.keys.map((service) {
                        return CheckboxListTile(
                          title: Text(service, style: const TextStyle(fontSize: 15, color: Colors.black87)),
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

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitGarage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A48FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Add Garage',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}