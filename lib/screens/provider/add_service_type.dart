// lib/screens/provider/add_service_type.dart

import 'package:flutter/material.dart';
import 'add_mechanic.dart';

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
          Padding(
            // ← Your original body now inside Stack
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          ),

          // Loading overlay - NEW in this commit
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
        onTap: onTap,
      ),
    );
  }
}
