// lib/screens/provider/add_service_type.dart

import 'package:flutter/material.dart';
import 'add_mechanic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        // ← NEW: Stack wrapper
        children: [
          const Text(
            'What type of service do you provide?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose one to create your provider profile',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // Mechanic card
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

          // Garage card
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

          // Tow Truck card
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

          // NEW in this commit: Service categories checkboxes grid
          const Text(
            'Select services you provide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // 2 columns on small screens
            childAspectRatio: 3.5, // make checkboxes wider
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

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final selectedServices = _serviceCategories.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList();

                      if (selectedServices.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select at least one service')),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          throw Exception('User not logged in');
                        }

                        await FirebaseFirestore.instance
                            .collection('providers')
                            .doc(user.uid)
                            .set(
                                {
                              'services': selectedServices,
                              'updatedAt': FieldValue.serverTimestamp(),
                              // You can add more fields later (e.g. 'name', 'email', 'role')
                            },
                                SetOptions(
                                    merge:
                                        true)); // merge so it doesn't overwrite other data

                        if (!mounted) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFFE6F4E6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.check,
                                      color: Colors.white, size: 50),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Success!',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const Text(
                                  'Services added to your profile!',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // close dialog
                                      Navigator.pop(
                                          context); // close add screen
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: const Text('OK',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Failed to add services: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF120A4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: const Text(
                'ADD SERVICES',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 32),
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
        onTap: onTap,
      ),
    );
  }
}
