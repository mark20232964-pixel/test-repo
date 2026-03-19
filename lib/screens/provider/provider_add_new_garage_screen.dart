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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Garage'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Garage Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Garage Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Contact Number
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Service Categories
                Column(
                  children: _serviceCategories.keys.map((service) {
                    return CheckboxListTile(
                      title: Text(service),
                      value: _serviceCategories[service],
                      onChanged: (val) {
                        setState(() {
                          _serviceCategories[service] = val!;
                        });
                      },
                    );
                  }).toList(),
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