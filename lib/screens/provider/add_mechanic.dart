// lib/screens/provider/add_mechanic.dart

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for current user
import 'package:cloud_firestore/cloud_firestore.dart'; // for saving mechanic data
import 'package:google_maps_flutter/google_maps_flutter.dart'; // for map widget
import 'package:geolocator/geolocator.dart'; // for live location & permissions
import 'package:http/http.dart' as http; // for Google Places autocomplete API

class AddMechanicScreen extends StatefulWidget {
  const AddMechanicScreen({super.key});

  @override
  State<AddMechanicScreen> createState() => _AddMechanicScreenState();
}

class _AddMechanicScreenState extends State<AddMechanicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Mechanic'),
        backgroundColor: const Color(0xFF120A4D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Mechanic Name'),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Phone is required';
                  if (value.length < 9) return 'Invalid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ListTile(
                title: const Text('Select Mechanic Location'),
                subtitle: Text(
                  _selectedLocation == null
                      ? 'Tap to open map and pick location'
                      : 'Selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                ),
                trailing:
                    const Icon(Icons.location_on, color: Color(0xFF120A4D)),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Map picker coming in next steps')),
                  );
                },
              ),

              const Spacer(),

              // NEW: Submit button + validation
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    if (_selectedLocation == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select location')),
                      );
                      return;
                    }

                    // Placeholder for future submit logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Mechanic details validated - submit coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF120A4D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Submit Mechanic Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  // Inner class for map picker screen
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Map Picker Screen - Coming in next commits')),
    );
  }
}
}
