// lib/screens/provider/our_services_screen.dart

import 'package:flutter/material.dart';

class OurServicesScreen extends StatelessWidget {
  const OurServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Our Services'),
        backgroundColor: const Color(0xFF1B1B4B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _showAddServiceDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add New Service"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A48FF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Service list (empty for now)
            const Expanded(
              child: Center(
                child: Text(
                  'No services yet. Tap Add New Service to start.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context, // ← this one stays (from showDialog)
      builder: (context) => AlertDialog(
        // ← builder gives a new context
        title: const Text("Add New Service"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Service Name"),
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Duration (e.g. 30 min)"),
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Price (e.g. 2000 LKR)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service added (coming soon)')),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
