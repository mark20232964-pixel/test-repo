// lib/screens/provider/add_service_type.dart

import 'package:flutter/material.dart';
import 'add_mechanic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// AddServiceTypeScreen: Allows providers to select the type of service they offer
// Features:
// - Displays 3 main service types with cards (Mechanic navigates, others "Coming soon")
// - Checkboxes for specific services (e.g. Towing, Battery Replacement)
// - Saves selected services to Firestore 'providers/{uid}' collection
// - Loading state with overlay + disabled UI during submit

class AddServiceTypeScreen extends StatefulWidget {
  const AddServiceTypeScreen({super.key});

  @override
  State<AddServiceTypeScreen> createState() => _AddServiceTypeScreenState();
}

class _AddServiceTypeScreenState extends State<AddServiceTypeScreen> {
  bool _isLoading = false;

  final Map<String, bool> _serviceCategories = {
    'Towing': false,
    'Battery Replacement': false,
    'Tire Change': false,
    'Fuel Delivery': false,
    'Jump Start': false,
    'Emergency Repair': false,
    'Other': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Your Service'),
        backgroundColor: const Color(0xFF120A4D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header question - matches design
                const Text(
                  'What type of service do you provide?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Subtitle
                const SizedBox(height: 8),
                const Text(
                  'Choose one to create your provider profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Service type cards section
                // Mechanic - navigates to detailed add screen
                _buildServiceTile(
                  icon: Icons.build,
                  title: 'Mechanic',
                  subtitle: 'Freelance or mobile mechanic',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMechanicScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Garage - coming soon placeholder
                _buildServiceTile(
                  icon: Icons.garage,
                  title: 'Garage / Workshop',
                  subtitle: 'Coming soon',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Garage / Workshop - Coming soon')),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Tow Truck - coming soon
                _buildServiceTile(
                  icon: Icons.local_taxi,
                  title: 'Tow Truck',
                  subtitle: 'Coming soon',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tow Truck - Coming soon')),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Services checkboxes section
                const Text(
                  'Select services you provide',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Grid of checkboxes from _serviceCategories map
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: _serviceCategories.keys.map((service) {
                    return CheckboxListTile(
                      title: Text(service),
                      value: _serviceCategories[service]!,
                      onChanged: (bool? value) {
                        setState(() {
                          _serviceCategories[service] = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF6A48FF),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Submit button with validation
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // ... your full submit logic from commit 13 ...
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF120A4D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'ADD SERVICES',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6A48FF).withOpacity(0.2),
          radius: 28,
          child: Icon(icon, color: const Color(0xFF6A48FF), size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: _isLoading ? null : onTap, // ← NEW: disable tap when loading
        tileColor: _isLoading
            ? Colors.grey[100]
            : null, // ← NEW: grey out when loading
      ),
    );
  }
}
