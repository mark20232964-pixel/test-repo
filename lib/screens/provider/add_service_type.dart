// lib/screens/provider/add_service_type.dart

import 'package:flutter/material.dart';
import 'add_mechanic.dart';

class AddServiceTypeScreen extends StatefulWidget {
  const AddServiceTypeScreen({super.key});

  @override
  State<AddServiceTypeScreen> createState() => _AddServiceTypeScreenState();
}

class _AddServiceTypeScreenState extends State<AddServiceTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Your Service'),
        backgroundColor: const Color(0xFF120A4D), // dark navy
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
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

            // Mechanic card (already there from commit 5)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6A48FF).withOpacity(0.2),
                  child: const Icon(Icons.build, color: Color(0xFF6A48FF)),
                ),
                title: const Text('Mechanic'),
                subtitle: const Text('Freelance or mobile mechanic'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMechanicScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Garage card - NEW in this commit
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6A48FF).withOpacity(0.2),
                  child: const Icon(Icons.garage, color: Color(0xFF6A48FF)),
                ),
                title: const Text('Garage / Workshop'),
                subtitle: const Text('Coming soon'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Garage / Workshop - Coming soon')),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            const Spacer(), // still temporary
          ],
        ),
      ),
    );
  }
}
