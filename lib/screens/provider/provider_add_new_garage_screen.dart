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
                

              ],
            ),
          ),
        ),
      ),
    );
  }
}