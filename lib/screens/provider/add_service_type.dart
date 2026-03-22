// lib/screens/provider/add_service_type.dart

import 'package:flutter/material.dart';
import 'add_mechanic.dart'; // your mechanic screen
import 'provider_add_new_garage_screen.dart'; // friend's garage screen

class AddServiceTypeScreen extends StatelessWidget {
  const AddServiceTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Service'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What type of service do you provide?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose one to create your provider profile',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildTile(
              context,
              Icons.build,
              "Mechanic",
              "Freelance or mobile mechanic",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMechanicScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTile(
              context,
              Icons.garage,
              "Garage / Workshop",
              "Garage / Workshop", // changed from "Coming soon" so it looks clickable
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProviderAddNewGarageScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTile(
              context,
              Icons.local_taxi,
              "Tow Truck",
              "Coming soon",
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Coming soon")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6A48FF).withOpacity(0.2),
          child: Icon(icon, color: const Color(0xFF6A48FF)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
